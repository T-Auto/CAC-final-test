<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Synchronized Clock</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            background-color: #ffffff;
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: 100vh;
            font-family: Arial, sans-serif;
        }

        .clock-container {
            display: flex;
            flex-direction: column;
            align-items: center;
            gap: 20px;
        }

        .analog-clock {
            position: relative;
            width: 80vmin;
            height: 80vmin;
            max-width: 400px;
            max-height: 400px;
            border: 8px solid #333;
            border-radius: 50%;
            background-color: #fff;
        }

        .clock-number {
            position: absolute;
            width: 100%;
            height: 100%;
            text-align: center;
            font-size: 6vmin;
            font-weight: bold;
            color: #333;
            transform-origin: center;
        }

        .clock-number:nth-child(1) { transform: rotate(30deg) translateY(-45%) rotate(-30deg); }
        .clock-number:nth-child(2) { transform: rotate(60deg) translateY(-45%) rotate(-60deg); }
        .clock-number:nth-child(3) { transform: rotate(90deg) translateY(-45%) rotate(-90deg); }
        .clock-number:nth-child(4) { transform: rotate(120deg) translateY(-45%) rotate(-120deg); }
        .clock-number:nth-child(5) { transform: rotate(150deg) translateY(-45%) rotate(-150deg); }
        .clock-number:nth-child(6) { transform: rotate(180deg) translateY(-45%) rotate(-180deg); }
        .clock-number:nth-child(7) { transform: rotate(210deg) translateY(-45%) rotate(-210deg); }
        .clock-number:nth-child(8) { transform: rotate(240deg) translateY(-45%) rotate(-240deg); }
        .clock-number:nth-child(9) { transform: rotate(270deg) translateY(-45%) rotate(-270deg); }
        .clock-number:nth-child(10) { transform: rotate(300deg) translateY(-45%) rotate(-300deg); }
        .clock-number:nth-child(11) { transform: rotate(330deg) translateY(-45%) rotate(-330deg); }
        .clock-number:nth-child(12) { transform: rotate(360deg) translateY(-45%) rotate(-360deg); }

        .hand {
            position: absolute;
            bottom: 50%;
            left: 50%;
            transform-origin: bottom center;
            border-radius: 5px 5px 0 0;
            background-color: #333;
        }

        .hour-hand {
            width: 6px;
            height: 30%;
            transform: translate(-50%, 0);
        }

        .minute-hand {
            width: 4px;
            height: 40%;
            transform: translate(-50%, 0);
        }

        .second-hand {
            width: 2px;
            height: 45%;
            background-color: #ff0000;
            transform: translate(-50%, 0);
            transition: transform 1s linear;
        }

        .digital-clock {
            font-size: 8vmin;
            font-weight: bold;
            color: #333;
            letter-spacing: 2px;
        }
    </style>
</head>
<body>
    <div class="clock-container">
        <div class="analog-clock">
            <div class="clock-number">1</div>
            <div class="clock-number">2</div>
            <div class="clock-number">3</div>
            <div class="clock-number">4</div>
            <div class="clock-number">5</div>
            <div class="clock-number">6</div>
            <div class="clock-number">7</div>
            <div class="clock-number">8</div>
            <div class="clock-number">9</div>
            <div class="clock-number">10</div>
            <div class="clock-number">11</div>
            <div class="clock-number">12</div>
            <div class="hand hour-hand"></div>
            <div class="hand minute-hand"></div>
            <div class="hand second-hand"></div>
        </div>
        <div class="digital-clock"></div>
    </div>

    <script>
        function updateClock() {
            const now = new Date();
            const hours = now.getHours();
            const minutes = now.getMinutes();
            const seconds = now.getSeconds();

            const hourDeg = (hours % 12) * 30 + minutes * 0.5;
            const minuteDeg = minutes * 6;
            const secondDeg = seconds * 6;

            document.querySelector('.hour-hand').style.transform = `translate(-50%, 0) rotate(${hourDeg}deg)`;
            document.querySelector('.minute-hand').style.transform = `translate(-50%, 0) rotate(${minuteDeg}deg)`;
            document.querySelector('.second-hand').style.transform = `translate(-50%, 0) rotate(${secondDeg}deg)`;

            const digitalTime = now.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit', second: '2-digit' });
            document.querySelector('.digital-clock').textContent = digitalTime;
        }

        updateClock();
        setInterval(updateClock, 1000);
    </script>
</body>
</html>