"use strict";
const BOARD_SIZE = 10;
const HERO_NAMES = [
    "",
    "npc_dota_hero_axe",
    "npc_dota_hero_crystal_maiden",
    "npc_dota_hero_pudge",
    "npc_dota_hero_invoker",
    "npc_dota_hero_antimage",
    "npc_dota_hero_juggernaut",
    "npc_dota_hero_phantom_assassin",
    "npc_dota_hero_furion"
];
let board = [];
let selectedRow = -1;
let selectedCol = -1;
let isProcessing = false;
let cells = [];
function GetHeroImagePath(heroType) {
    if (heroType <= 0 || heroType >= HERO_NAMES.length)
        return "";
    return "file://{images}/heroes/" + HERO_NAMES[heroType] + ".png";
}
function CreateBoard() {
    const boardPanel = $("#Board");
    if (!boardPanel)
        return;
    for (let row = 0; row < BOARD_SIZE; row++) {
        cells[row] = [];
        board[row] = [];
        for (let col = 0; col < BOARD_SIZE; col++) {
            board[row][col] = 0;
            const cell = $.CreatePanel("Panel", boardPanel, "cell_" + row + "_" + col);
            cell.AddClass("cell");
            const img = $.CreatePanel("Image", cell, "img_" + row + "_" + col);
            const r = row;
            const c = col;
            cell.SetPanelEvent("onactivate", function () {
                OnCellClicked(r, c);
            });
            cells[row][col] = cell;
        }
    }
}
function OnCellClicked(row, col) {
    if (isProcessing)
        return;
    if (selectedRow === -1) {
        SelectCell(row, col);
        return;
    }
    if (selectedRow === row && selectedCol === col) {
        DeselectCell();
        return;
    }
    const dr = Math.abs(row - selectedRow);
    const dc = Math.abs(col - selectedCol);
    if ((dr === 1 && dc === 0) || (dr === 0 && dc === 1)) {
        RequestSwap(selectedRow, selectedCol, row, col);
        DeselectCell();
    }
    else {
        DeselectCell();
        SelectCell(row, col);
    }
}
function SelectCell(row, col) {
    selectedRow = row;
    selectedCol = col;
    cells[row][col].AddClass("selected");
}
function DeselectCell() {
    if (selectedRow >= 0 && selectedCol >= 0) {
        cells[selectedRow][selectedCol].RemoveClass("selected");
    }
    selectedRow = -1;
    selectedCol = -1;
}
function RequestSwap(row1, col1, row2, col2) {
    isProcessing = true;
    GameEvents.SendCustomGameEventToServer("match3_swap_request", {
        row1: row1 + 1,
        col1: col1 + 1,
        row2: row2 + 1,
        col2: col2 + 1
    });
}
function UpdateBoard(boardStr) {
    for (let i = 0; i < boardStr.length && i < BOARD_SIZE * BOARD_SIZE; i++) {
        const row = Math.floor(i / BOARD_SIZE);
        const col = i % BOARD_SIZE;
        const heroType = parseInt(boardStr[i]);
        board[row][col] = heroType;
        const imgPanel = cells[row][col].FindChild("img_" + row + "_" + col);
        if (imgPanel) {
            const path = GetHeroImagePath(heroType);
            if (path) {
                imgPanel.SetImage(path);
            }
        }
    }
}
function UpdateScore(score) {
    const scoreLabel = $("#ScoreValue");
    if (scoreLabel) {
        scoreLabel.text = score.toString();
    }
}
function ShowCombo(combo) {
    const comboLabel = $("#ComboLabel");
    if (comboLabel) {
        if (combo > 1) {
            comboLabel.text = combo + "x COMBO!";
            $.Schedule(1.5, function () {
                comboLabel.text = "";
            });
        }
        else {
            comboLabel.text = "";
        }
    }
}
function ShowMessage(msg) {
    const msgLabel = $("#MessageLabel");
    if (msgLabel) {
        msgLabel.text = msg;
        msgLabel.AddClass("visible");
        $.Schedule(2.0, function () {
            msgLabel.RemoveClass("visible");
        });
    }
}
function OnBoardUpdate(data) {
    isProcessing = false;
    UpdateBoard(data.board);
    UpdateScore(data.score);
    ShowCombo(data.combo);
    if (data.no_moves) {
        ShowMessage("No valid moves - board reshuffled!");
    }
}
function OnSwapRejected() {
    isProcessing = false;
    Game.EmitSound("General.Cancel");
}
(function Init() {
    CreateBoard();
    GameEvents.Subscribe("match3_board_update", OnBoardUpdate);
    GameEvents.Subscribe("match3_swap_rejected", OnSwapRejected);
    $.Schedule(0.5, function () {
        GameEvents.SendCustomGameEventToServer("match3_request_board", {});
    });
})();
