document.addEventListener("DOMContentLoaded", () => {

  const playButton = document.getElementById("playButton");
  const nameInput = document.querySelector('[name="name"]');
  const levelSelect = document.querySelector('[name="level"]');
  const errorMessage = document.getElementById("error-message");

  function validateForm() {
    const nameValid = nameInput.value.trim() !== "";
    const levelValid = levelSelect.value !== "";

    if (nameValid && levelValid) {
      playButton.disabled = false;
      errorMessage.classList.add("hide");
    } else {
      playButton.disabled = true;
      if (nameInput.value.trim() !== "") {
        errorMessage.classList.remove("hide");
      }
    }
  }

  nameInput.addEventListener("input", validateForm);
  levelSelect.addEventListener("change", validateForm);

  validateForm();
});

class Game {
    constructor() {
        this.clicked = false;
        this.countdown = 3;
        this.time = 0;
        this.countdownInterval = null;
        this.targetInterval = null;
        this.gameRunning = false;
        this.paused = false;
        // this.board = document.querySelector(".board");
        this.initialize();
    }

    initialize(){

    }

    


}

function getScoreNow(){
        const getName = localStorage.getItem('name');
        document.getElementById('boardLeftScore').innerHTML = `
            <div class="scoreBoard">
                <h3>Player: ${getName}</h3>
                <h3>Time: ${this.time}</h3>
                    // Heart Logic 
                    <h1>❤️❤️❤️</h1>
                <img src="images/wall_crack.png" alt="Wall Crack"><h1> = ${this.wallCrack}</h1>
                <img src="images/tnt.png" alt="Tnt"><h1> = ${this.tnt}</h1>
                <img src="images/ice.png" alt="Ice"><h1> = ${this.ice}</h1>
            </div>
        `;
    }

function gameOver(){
        document.querySelector(".gameOver").classList.remove("hide");
        document.getElementById('gameOver').innerHTML = 
        `   
            <div class="centerGameOverText">
                <h1>Game Over!</h1>
                <h3>Good job ${this.name} your time ${this.time} with results:</h3>
            </div>
            <div class="centergameOverImage">
                <div class="GameOverwallBreak">
                    <img src="images/wall_crack.png" alt="Wall Crack"> = ${this.resultWallCrack}
                </div>
                <div class="GameOverTnt">
                    <img src="images/tnt.png" alt="Tnt"> = ${this.resultTnt}
                </div>
                <div class="GameOverIce">
                    <img src="images/ice.png" alt="Ice"> = ${this.resultIce}
                </div>
            </div>
            
            <div class="centerButtonGameOver">
                <button class="buttonGameOverSaveScore" onclick="saveScore()" aria-label="Save Score">
                    Save Score
                </button>
                <button class="buttonGameOverLeaderBoards" onclick="leaderBoard()" aria-label="Leaderboards">
                    Leaderboards
                </button>
            </div>
        `;
}

function leaderBoard(){
    document.querySelector(".gameOver").classList.add('hide');
    document.querySelector(".leaderBoards").classList.remove("hide");
           document.getElementById('leaderBoards').innerHTML = `
            <div class="leaderBoardsCenterText">
                <h1>Leaderboards</h1>
                <table border="1">
                    <tr>
                        <th>Player Name</th>
                        <th>Time</th>
                        <th><img src="images/wall_crack.png" alt="Wall Crack"></th>
                        <th><img src="images/tnt.png" alt="Tnt"></th>
                        <th><img src="images/ice.png" alt="Ice"></th>
                    </tr>
                    <tr>
                        <td>// Menampilkan dari fecthing Leader Boards</td>
                        <td>// Menampilkan dari fecthing Leader Boards</td>
                        <td>// Menampilkan dari fecthing Leader Boards</td>
                        <td>// Menampilkan dari fecthing Leader Boards</td>
                        <td>// Menampilkan dari fecthing Leader Boards</td>
                    </tr>
                </table>
            </div>
            <div class="leaderBoardsCenterButton">
                <button class="buttonLeaderboardsPlayAgain" onclick="play()" id="playButton"" aria-label="Play Again">
                    Play Again
                </button>
                <button class="buttonLeaderboardReset" onclick="reset()" aria-label="Reset">
                    Reset
                </button>
            </div>
        `
}

function fetchingLeaderboards() {
    localStorage.getItem('name');
    localStorage.getItem('time');
    localStorage.getItem('wallBreak');
    localStorage.getItem('Ice');
}

function play(){

}

function showInstruction() {
  document.querySelector(".instructBoard").classList.remove("hide");
}