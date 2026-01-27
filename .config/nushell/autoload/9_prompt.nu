# ===== 色定義 (Hex PCCS) =====
let GREEN_BRIGHT = '#41b879'
let GREEN_LIGHTP = '#85ce9e'
let GREEN_PALEP = '#aed4b9'
let GRAY = '#a1a1a1'

# ===== 環境判定関数 =====

# Docker/LXC内かを検出
def is-in-container [] {
  if ('/proc/1/cgroup' | path exists) {
    let content = (open /proc/1/cgroup --raw)
    ($content | str contains 'docker') or ($content | str contains 'lxc')
  } else {
    false
  }
}

# SSH接続かを検出
def is-ssh [] {
  'SSH_CONNECTION' in $env
}

# ===== Git情報取得関数 =====

# Git情報を取得してプロンプト用の文字列を生成
def my-git-ps1 [] {
  # git status --show-stashの実行
  let status = (do -i { git status --show-stash } | complete)

  if $status.exit_code != 0 {
    return ''
  }

  let status_text = $status.stdout

  # ブランチ名の取得
  let branch = if ($status_text | str contains 'HEAD detached') {
    # "HEAD detached at" または "HEAD detached from" の両方に対応
    let match = ($status_text | parse --regex 'HEAD detached (?:at|from) (?P<branch>\S+)' | first)
    if ($match | is-not-empty) {
      $"(($match.branch))"
    } else {
      ''
    }
  } else if ($status_text | str contains 'On branch') {
    let lines = ($status_text | lines)
    let first_line = ($lines | first)
    ($first_line | str replace 'On branch ' '')
  } else {
    ''
  }

  # ファイル状態の検出
  mut file_markers = ''

  # No commits yet
  if ($status_text | str contains 'No commits yet') {
    $file_markers = ($file_markers + '#')
  }

  # Changes not staged for commit または Unmerged paths
  if (($status_text | str contains 'Changes not staged for commit') or
      ($status_text | str contains 'Unmerged paths')) {
    $file_markers = ($file_markers + '*')
  }

  # Changes to be committed
  if ($status_text | str contains 'Changes to be committed') {
    $file_markers = ($file_markers + '+')
  }

  # Stash
  let stash = if ($status_text | str contains 'Your stash') { '$' } else { '' }

  # Untracked files
  let untracked = if ($status_text | str contains 'Untracked files') { '%' } else { '' }

  $file_markers = ($file_markers + $stash + $untracked)

  let file_part = if ($file_markers | str length) > 0 {
    $'|($file_markers)'
  } else {
    ''
  }

  # Sparse checkout
  let sparse = if ($status_text | str contains 'You are in a sparse checkout') {
    '|SPARSE'
  } else {
    ''
  }

  # Upstream情報
  mut upstream = ''

  # ahead/behind検出
  if ($status_text | str contains 'Your branch is') {
    let ahead_match = ($status_text | parse --regex "Your branch is (ahead of|behind) '(?P<remote>[^']+)'( by (?P<commits>\\d+) commit)?" | first)

    if ($ahead_match | is-not-empty) {
      let direction = if ($ahead_match.capture0 == 'ahead of') { '+' } else { '-' }
      let commits = if ('commits' in $ahead_match) { $ahead_match.commits } else { '' }
      $upstream = $'|u($direction)($commits) ($ahead_match.remote)'
    }
  }

  # diverged検出
  if ($status_text | str contains 'have diverged') {
    let diverged_match = ($status_text | parse --regex "Your branch and '(?P<remote>[^']+)' have diverged,.*and have (?P<ahead>\\d+) and (?P<behind>\\d+) different commits" | first)

    if ($diverged_match | is-not-empty) {
      $upstream = $'|u+($diverged_match.ahead)-($diverged_match.behind) ($diverged_match.remote)'
    }
  }

  # Operation状態
  mut operation = ''
  mut conflict = ''

  if ($status_text | str contains 'You are currently bisecting') {
    $operation = '|BISECTING'
  }

  if ($status_text | str contains 'You are currently rebasing') {
    $operation = '|REBASE'
  }

  if (($status_text | str contains 'you are still merging') or
      ($status_text | str contains 'You have unmerged paths')) {
    $operation = '|MERGING'
  }

  if ($status_text | str contains 'Unmerged paths') {
    $conflict = '|CONFLICT'
  }

  # 結果を結合
  $'($branch)($file_part)($sparse)($upstream)($operation)($conflict)'
}

# ===== プロンプト生成関数 =====

def create-prompt [] {
  let last_exit = $env.LAST_EXIT_CODE

  mut prompt_parts = []

  # 改行
  $prompt_parts = ($prompt_parts | append "\n")

  # バックグラウンドジョブ数の表示
  let job_count = (job list | length)
  if $job_count > 0 {
    $prompt_parts = ($prompt_parts | append $"(ansi { fg: ($GREEN_BRIGHT) })& (ansi reset)")
  }

  # LOCAL_PS1の表示
  if 'LOCAL_PS1' in $env {
    $prompt_parts = ($prompt_parts | append $"(ansi { fg: ($GREEN_LIGHTP) })($env.LOCAL_PS1)|(ansi reset)")
  }

  # ユーザー名とホスト名
  let user_host = if (is-ssh) or (is-in-container) {
    # SSH接続またはコンテナ内の場合は下線付きでuser@hostを表示
    let hostname = (hostname | str trim)
    $"(ansi { fg: ($GREEN_LIGHTP) attr: u })($env.USER)@($hostname)(ansi reset)"
  } else {
    # ローカルの場合はユーザー名のみ
    $"(ansi { fg: ($GREEN_LIGHTP) })($env.USER)(ansi reset)"
  }
  $prompt_parts = ($prompt_parts | append $user_host)

  # カレントディレクトリ
  let current_dir = if ($env.PWD | str starts-with $nu.home-path) {
    $"~(($env.PWD | str substring ($nu.home-path | str length)..))"
  } else {
    $env.PWD
  }
  $prompt_parts = ($prompt_parts | append $" (ansi { fg: ($GREEN_PALEP) })($current_dir)(ansi reset)")

  # Git情報
  let git_info = (my-git-ps1)
  if ($git_info | str length) > 0 {
    $prompt_parts = ($prompt_parts | append $" (ansi { fg: ($GRAY) })($git_info)(ansi reset)")
  }

  # CONTEXT変数 (存在する場合)
  if 'CONTEXT' in $env {
    $prompt_parts = ($prompt_parts | append $" ($env.CONTEXT)")
  }

  # 改行
  $prompt_parts = ($prompt_parts | append "\n")

  # プロンプト記号 (終了コードに応じて色を変える)
  let prompt_symbol = if $last_exit == 0 {
    $"(ansi { fg: ($GREEN_LIGHTP) })$(ansi reset) "
  } else {
    $"(ansi { fg: ($GRAY) })$(ansi reset) "
  }
  $prompt_parts = ($prompt_parts | append $prompt_symbol)

  # 結合して返す
  $prompt_parts | str join ''
}

# ===== プロンプト設定 =====

$env.PROMPT_COMMAND = {|| create-prompt }
$env.PROMPT_INDICATOR = ""
$env.PROMPT_COMMAND_RIGHT = ""
$env.PROMPT_MULTILINE_INDICATOR = ": "
