"""
logger.py — 轻量统一日志模块（单文件）

特性：
1) 顶部全局变量即可完成参数配置；
2) 支持 5 个等级：debug / info / warning / error / critical；
3) 可切换是否输出到控制台与文件；
4) 控制台不同等级可配字体颜色（含默认值）；
5) 若开启文件日志：需配置日志目录；每次程序启动生成独立日志文件，如 20251107_142407.log；
6) 提供多种记录方式：debug()/info()/warning()/error()/critical()、exception()、log()、log_json()、log_duration() 计时器等。

用法示例：
    import logger as L
    L.info("hello")
    with L.log_duration("big task"):
        ...

无第三方强依赖。若安装了 colorama，将自动在 Windows 上启用彩色输出。
"""
from __future__ import annotations

import atexit
import json
import logging
import os
import sys
import threading
from contextlib import contextmanager
from datetime import datetime
from typing import Any, Dict, Optional

# ==============================
# 全局配置（按需修改）
# ==============================
# 是否输出到控制台
ENABLE_CONSOLE: bool = True
# 是否输出到文件
ENABLE_FILE: bool = False
# 日志目录（ENABLE_FILE=True 时生效）
LOG_DIR: str = "logs"
# 最小日志等级（'DEBUG'/'INFO'/'WARNING'/'ERROR'/'CRITICAL'）
MIN_LEVEL: str = "DEBUG"
# 控制台是否使用颜色
USE_COLOR: bool = True
# 各等级默认颜色（ANSI 转义码；Windows 推荐安装 colorama 以自动适配）
# DEBUG=青色, INFO=绿色, WARNING=黄色, ERROR=红色, CRITICAL=白字红底
LEVEL_COLORS: Dict[str, str] = {
    "DEBUG": "36",       # Cyan
    "INFO": "32",        # Green
    "WARNING": "33",     # Yellow
    "ERROR": "31",       # Red
    "CRITICAL": "41;97", # BG Red; FG Bright White
}
# 控制台与文件的格式
CONSOLE_FORMAT: str = "[%(asctime)s] [%(levelname)s] %(message)s"
FILE_FORMAT: str = "[%(asctime)s] [%(levelname)s] [%(name)s] %(message)s"
DATE_FORMAT: str = "%Y-%m-%d %H:%M:%S"
# 日志器名称（通常无需修改）
LOGGER_NAME: str = "app"

# ==============================
# 内部状态（勿手动修改）
# ==============================
_START_TIME: datetime = datetime.now()
_START_STAMP: str = _START_TIME.strftime("%Y%m%d_%H%M%S")
_LOGGER: Optional[logging.Logger] = None
_LOG_FILE_PATH: Optional[str] = None
_CONFIG_LOCK = threading.RLock()

# Windows 颜色兼容（可选）
try:  # 若安装了 colorama，则初始化以支持 Windows 彩色输出
    import colorama  # type: ignore

    colorama.just_fix_windows_console()  # 开启原生 ANSI 支持
except Exception:
    pass


class _ColorFormatter(logging.Formatter):
    """根据等级为 levelname 着色，仅用于控制台 Handler。"""

    def __init__(self, fmt: str, datefmt: str, use_color: bool, level_colors: Dict[str, str]):
        super().__init__(fmt=fmt, datefmt=datefmt)
        self.use_color = use_color
        self.level_colors = level_colors

    def format(self, record: logging.LogRecord) -> str:
        original_levelname = record.levelname
        if self.use_color:
            code = self.level_colors.get(original_levelname)
            if code:
                record.levelname = f"\033[{code}m{original_levelname}\033[0m"
        try:
            return super().format(record)
        finally:
            record.levelname = original_levelname  # 还原，避免影响其他 handler


def _str_to_level(level_name: str) -> int:
    try:
        return getattr(logging, level_name.upper())
    except Exception:
        return logging.INFO


def _ensure_dir(path: str) -> None:
    os.makedirs(path, exist_ok=True)


def _build_file_path() -> str:
    global _LOG_FILE_PATH
    if _LOG_FILE_PATH:
        return _LOG_FILE_PATH
    _ensure_dir(LOG_DIR)
    _LOG_FILE_PATH = os.path.join(LOG_DIR, f"{_START_STAMP}.log")
    return _LOG_FILE_PATH


def _clear_handlers(lg: logging.Logger) -> None:
    for h in list(lg.handlers):
        try:
            lg.removeHandler(h)
            try:
                h.flush()
            except Exception:
                pass
            try:
                h.close()
            except Exception:
                pass
        except Exception:
            pass


def _configure() -> logging.Logger:
    """按当前全局变量配置日志器（幂等）。"""
    global _LOGGER
    with _CONFIG_LOCK:
        if _LOGGER is None:
            _LOGGER = logging.getLogger(LOGGER_NAME)
        lg = _LOGGER
        lg.setLevel(_str_to_level(MIN_LEVEL))
        _clear_handlers(lg)

        # 控制台
        if ENABLE_CONSOLE:
            ch = logging.StreamHandler(stream=sys.stdout)
            ch.setLevel(_str_to_level(MIN_LEVEL))
            ch.setFormatter(
                _ColorFormatter(CONSOLE_FORMAT, DATE_FORMAT, USE_COLOR, LEVEL_COLORS)
            )
            lg.addHandler(ch)

        # 文件
        if ENABLE_FILE:
            try:
                fp = _build_file_path()
                fh = logging.FileHandler(fp, encoding="utf-8")
                fh.setLevel(_str_to_level(MIN_LEVEL))
                fh.setFormatter(logging.Formatter(FILE_FORMAT, DATE_FORMAT))
                lg.addHandler(fh)
            except Exception as e:
                # 文件不可用时退化为仅控制台，并告警到 stderr（避免递归日志）
                print(f"[logger] Failed to create log file: {e}", file=sys.stderr)

        # 使第三方库日志不向上冒泡至 root，避免重复
        lg.propagate = False

        # 记录启动信息
        # lg.info("================ Program started: %s ================", _START_TIME.strftime(DATE_FORMAT))
        # lg.debug(
        #     "logger configured: console=%s, file=%s, level=%s, log_dir=%s, file_path=%s",
        #     ENABLE_CONSOLE,
        #     ENABLE_FILE,
        #     MIN_LEVEL,
        #     LOG_DIR,
        #     _LOG_FILE_PATH,
        # )
        return lg


# 对外暴露：获取底层 logger
def get_logger() -> logging.Logger:
    global _LOGGER
    if _LOGGER is None:
        _configure()
    assert _LOGGER is not None
    return _LOGGER


# 对外暴露：当前日志文件路径（可能为 None）
def current_log_file() -> Optional[str]:
    return _LOG_FILE_PATH


# 对外暴露：当修改了全局变量后，可调用以重新生效
def reload_config() -> None:
    _configure()


# =============
# 便捷记录方法
# =============

def log(level: str, msg: str, *args: Any, **kwargs: Any) -> None:
    get_logger().log(_str_to_level(level), msg, *args, **kwargs)


def debug(msg: str, *args: Any, **kwargs: Any) -> None:
    get_logger().debug(msg, *args, **kwargs)


def info(msg: str, *args: Any, **kwargs: Any) -> None:
    get_logger().info(msg, *args, **kwargs)


def warning(msg: str, *args: Any, **kwargs: Any) -> None:
    get_logger().warning(msg, *args, **kwargs)


def error(msg: str, *args: Any, **kwargs: Any) -> None:
    get_logger().error(msg, *args, **kwargs)


def critical(msg: str, *args: Any, **kwargs: Any) -> None:
    get_logger().critical(msg, *args, **kwargs)


def exception(msg: str = "", exc: Optional[BaseException] = None) -> None:
    """记录异常堆栈（等同于 logging.exception）。

    Args:
        msg: 可选前缀信息。
        exc: 指定异常；默认使用当前 except 块中的异常。
    """
    lg = get_logger()
    if exc is not None:
        lg.error(msg or str(exc), exc_info=exc)
    else:
        lg.exception(msg or "Unhandled exception")


def log_json(data: Any, level: str = "INFO", *, ensure_ascii: bool = False, indent: Optional[int] = None) -> None:
    """以 JSON 格式输出结构化数据。"""
    try:
        text = json.dumps(data, ensure_ascii=ensure_ascii, indent=indent, default=str)
    except TypeError:
        # 兜底转换
        text = json.dumps(str(data), ensure_ascii=ensure_ascii)
    log(level, text)


@contextmanager
def log_duration(title: str, level: str = "INFO"):
    """上下文管理器：统计代码块耗时。

    with log_duration("load data"):
        ...
    """
    import time

    start = time.perf_counter()
    log(level, f"⏱️ {title} - start")
    try:
        yield
    except Exception as e:
        # 先记录，再抛出
        exception(f"{title} - failed", e)
        raise
    else:
        cost = (time.perf_counter() - start) * 1000
        log(level, f"⏱️ {title} - done in {cost:.2f} ms")


# =============
# 模块导入即配置
# =============
_configure()


@atexit.register
def _on_exit() -> None:
    try:
        get_logger().info(
            "================ Program ended: %s ================",
            datetime.now().strftime(DATE_FORMAT),
        )
    except Exception:
        pass




