<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>简单计算器</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
            margin: 0;
            background-color: #f0f0f0;
        }
        
        .calculator {
            background-color: #333;
            border-radius: 10px;
            padding: 20px;
            box-shadow: 0 0 20px rgba(0, 0, 0, 0.3);
        }
        
        #display {
            width: 100%;
            height: 80px;
            background-color: #fff;
            margin-bottom: 20px;
            border-radius: 5px;
            display: flex;
            flex-direction: column;
            justify-content: flex-end;
            align-items: flex-end;
            padding: 10px;
            box-sizing: border-box;
            font-size: 24px;
            overflow: hidden;
        }
        
        #display input {
            width: 100%;
            border: none;
            text-align: right;
            font-size: 32px;
            margin-bottom: 5px;
            background-color: transparent;
        }
        
        #display input:focus {
            outline: none;
        }
        
        #result {
            font-size: 18px;
            color: #666;
        }
        
        .buttons {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 10px;
        }
        
        button {
            width: 70px;
            height: 70px;
            font-size: 24px;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            background-color: #666;
            color: #fff;
        }
        
        button:hover {
            background-color: #888;
        }
        
        button:active {
            background-color: #444;
        }
        
        .operator {
            background-color: #ff9500;
        }
        
        .operator:hover {
            background-color: #ffb74d;
        }
        
        .operator:active {
            background-color: #e68900;
        }
        
        #clear {
            background-color: #ff3b30;
        }
        
        #clear:hover {
            background-color: #ff6b6b;
        }
        
        #clear:active {
            background-color: #cc2e25;
        }
        
        #delete {
            background-color: #007aff;
        }
        
        #delete:hover {
            background-color: #58a4ff;
        }
        
        #delete:active {
            background-color: #0056b3;
        }
        
        #equals {
            background-color: #34c759;
        }
        
        #equals:hover {
            background-color: #66d37a;
        }
        
        #equals:active {
            background-color: #29a046;
        }
    </style>
</head>
<body>
    <div class="calculator">
        <div id="display">
            <input type="text" id="input" readonly>
            <div id="result"></div>
        </div>
        <div class="buttons">
            <button id="clear">C</button>
            <button id="delete">DEL</button>
            <button class="operator">/</button>
            <button class="operator">*</button>
            <button class="number">7</button>
            <button class="number">8</button>
            <button class="number">9</button>
            <button class="operator">-</button>
            <button class="number">4</button>
            <button class="number">5</button>
            <button class="number">6</button>
            <button class="operator">+</button>
            <button class="number">1</button>
            <button class="number">2</button>
            <button class="number">3</button>
            <button id="equals">=</button>
            <button class="number">0</button>
            <button class="number">.</button>
        </div>
    </div>

    <script>
        const input = document.getElementById('input');
        const result = document.getElementById('result');
        const buttons = document.querySelectorAll('button');
        
        let currentInput = '';
        let previousInput = '';
        let operator = '';
        
        buttons.forEach(button => {
            button.addEventListener('click', () => {
                const value = button.textContent;
                
                if (button.classList.contains('number')) {
                    if (value === '.' && currentInput.includes('.')) return;
                    currentInput += value;
                    input.value = currentInput;
                } else if (button.classList.contains('operator')) {
                    if (currentInput === '') return;
                    if (previousInput !== '') {
                        calculate();
                    }
                    previousInput = currentInput;
                    operator = value;
                    currentInput = '';
                    result.textContent = previousInput + ' ' + operator;
                } else if (button.id === 'equals') {
                    calculate();
                } else if (button.id === 'clear') {
                    clearAll();
                } else if (button.id === 'delete') {
                    currentInput = currentInput.slice(0, -1);
                    input.value = currentInput;
                }
            });
        });
        
        function calculate() {
            if (previousInput === '' || currentInput === '' || operator === '') return;
            
            let res;
            const prev = parseFloat(previousInput);
            const curr = parseFloat(currentInput);
            
            switch (operator) {
                case '+':
                    res = prev + curr;
                    break;
                case '-':
                    res = prev - curr;
                    break;
                case '*':
                    res = prev * curr;
                    break;
                case '/':
                    if (curr === 0) {
                        result.textContent = '错误：除数不能为0';
                        clearAll();
                        return;
                    }
                    res = prev / curr;
                    break;
            }
            
            input.value = res;
            result.textContent = previousInput + ' ' + operator + ' ' + currentInput + ' = ' + res;
            previousInput = res.toString();
            currentInput = '';
            operator = '';
        }
        
        function clearAll() {
            currentInput = '';
            previousInput = '';
            operator = '';
            input.value = '';
            result.textContent = '';
        }
    </script>
</body>
</html>