from typing import Optional
import os
import sys


def md_to_string(file_path: str, encoding: str = "utf-8") -> str:
    """
    读取指定 Markdown 文件并返回完整字符串内容。
    
    Args:
        file_path: Markdown 文件路径
        encoding: 文件编码，默认 utf-8
        
    Returns:
        str: 文件内容（可能很长）
        
    Raises:
        FileNotFoundError: 当文件不存在时
        IsADirectoryError: 当传入路径为目录时
        UnicodeDecodeError: 当解码失败时
        OSError: 其他文件系统相关错误
    """
    if not os.path.exists(file_path):
        raise FileNotFoundError(f"文件不存在: {file_path}")
    if os.path.isdir(file_path):
        raise IsADirectoryError(f"不是文件而是目录: {file_path}")
    
    with open(file_path, "r", encoding=encoding) as f:
        return f.read()


def _main(argv: Optional[list] = None) -> int:
    """
    简单的 CLI：传入一个 Markdown 文件路径到标准输出打印其内容。
    
    用法:
        python -m src.md2str <path-to-markdown>
    """
    args = sys.argv[1:] if argv is None else argv
    if len(args) != 1:
        print("用法: python -m src.md2str <markdown_file_path>", file=sys.stderr)
        return 2
    file_path = args[0]
    try:
        content = md_to_string(file_path)
        # 打印到标准输出，供管道或其他程序捕获
        sys.stdout.write(content)
        return 0
    except Exception as e:
        print(f"[ERROR] 读取失败: {e}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(_main())

