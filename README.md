# ColosseumCLI

預先建置、自帶完整執行環境的 `colo` 部署執行檔——不含原始碼、目標機器也不需要安裝 .NET
runtime。此 repo 存在的唯一目的，就是讓一台新的 worker 機器可以直接 `git clone` 後立即部署，
不需要再 checkout 完整的 `colosseum` 原始碼樹並自行建置。

由 [colosseum/colosseum_cli](https://github.com/ej3muse/colosseum/tree/main/colosseum_cli)
透過 `colosseum_cli/release_binary.sh` 建置產出。此 repo 中的 `VERSION` 檔記錄了每次 release
對應的確切原始碼 commit 與建置時間。

## 內容物

- `dist/colo` — `colo` CLI 本體（self-contained、linux-x64、單一檔案）
- `dist/colosseum-worker` — `colo deploy` 會啟動的每一個 agent 執行層 worker
- `config/subjects.yaml` — 版本化的 NATS subject/timeout 設定範本，`colo` 需要以此作為錨點目錄
  （它會從自己執行檔所在位置往上層尋找 `config/subjects.yaml`）

兩支執行檔都是完全 self-contained：.NET 8 runtime 已內建在檔案中，因此目標機器除了 Linux
x86_64 使用者環境（`sudo`、`useradd`、互動式 CLI agent 所需的 `sshd`——與任何 `colo deploy`
所需的作業系統層級需求相同）之外，不需要預先安裝任何東西（包含 `dotnet`）。

## 在新機器上安裝

```bash
curl -fsSL https://raw.githubusercontent.com/ej3muse/ColosseumCLI/main/install.sh | bash
```

不需要選擇路徑，也不需要建置步驟。與 Claude Code / Codex CLI 的安裝方式相同：安裝程式會
clone 到一個固定、由工具自行管理的位置（`$XDG_DATA_HOME/colosseum-cli`，預設即
`~/.local/share/colosseum-cli`），將 `colo` 以 symlink 方式連結到 `~/.local/bin`，並在該路徑
尚未加入你的 shell PATH 時自動加入。若需要自訂安裝位置，可在執行安裝程式前設定
`COLOSSEUM_CLI_INSTALL_DIR=/some/path`。

**如果 `~/.local/bin` 原本不在你的 PATH 中**，安裝程式會印出警告，但無法修改你「目前這個」
shell 的環境（因為它是以 `curl | bash` 的子行程執行，子行程無法改變父行程的環境變數）。請務必
照它印出的指示操作：開新的終端機視窗，或執行它印出的 `source ...` 指令，**再**執行
`colo deploy`。若把 `colo deploy` 直接接在安裝一行指令的同一行執行，在 `~/.local/bin` 原本不在
PATH 的機器上，第一次一定會靜默地出現「command not found」錯誤。

想自己管理這份 checkout 嗎？可以把這個 repo clone 到任何位置——`colo` 會從執行檔所在位置往上
尋找自己的設定（尋找 `config/subjects.yaml`），所以只要 `dist/` 與 `config/` 維持在一起，放在
任何地方都可以：

```bash
git clone https://github.com/ej3muse/ColosseumCLI.git <wherever-you-want>
ln -sf <wherever-you-want>/dist/colo ~/.local/bin/colo
```

## 更新

重新執行安裝程式即可——它可以安全地重複執行，只會快轉到最新的 release。因為 `colo` 在第一次
安裝後就已經在 PATH 上了，之後更新不會遇到上面提到的新 shell 問題：

```bash
curl -fsSL https://raw.githubusercontent.com/ej3muse/ColosseumCLI/main/install.sh | bash
colo deploy
```

## 使用方式

1. 使用者需先登入 ColosseumCTF 網站。
2. 使用者於 ColosseumCTF 網站中設定 agent profiles（包括每個角色有哪些 agent，以及 agent
   相關的 LLM agent / LLM 模型設定）。
3. 使用者於 war room 中產生 token（若先前已產生過 token，無法再取得之前的 token，只能將舊
   token 撤銷後重新產生）。
4. 使用者執行 `colo deploy` 進行部署，部署過程中需要指定 Colosseum 主機位址以及 token，連線
   Colosseum 主機後，會查詢使用者所設定之 agent profile，並為每個 agent 建立一個與 agent 同名
   的 Linux 帳號。
5. 使用者於部署完成後執行 `colo` 指令，等待 ColosseumCTF 網站所指派的命令。
6. 使用者於 ColosseumCTF 網站送出訊息後，即會透過 orchestrator 轉交給指定或自行判斷的 agent
   處理（attack and defense 類型題目預設會交由擔任 attack and defense solver 的 agent 處理、
   king of hill 類型題目預設會交由擔任 king of hill solver 的 agent 處理，使用者亦可自行新增
   角色並手動指定；若對應角色無負責之 agent，則由 orchestrator 自行處理）。
7. 處理過程會顯示於 colosseum cli 畫面中，處理完後會將結果紀錄於 agent 自身帳號內的
   `history.md` 中，並更新 `memory.md` 內容，最後透過 orchestrator 回傳給 ColosseumCTF 網站。
