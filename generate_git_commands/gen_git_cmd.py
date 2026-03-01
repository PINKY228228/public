import argparse


def generate_git_commands(
    repo_url: str,
    branch: str,
    clone_dir: str,
    commit_message: str = "update"
) -> str:
    cmds = [
        f"git clone -b {branch} {repo_url} {clone_dir}",
        f"cd {clone_dir}",
        "git status",
        "# ---- ファイル編集 ----",
        "git add .",
        f'git commit -m "{commit_message}"',
        f"git push origin {branch}",
    ]
    return "\n".join(cmds)


def main():
    parser = argparse.ArgumentParser(
        description="Generate git command sequence (text only)"
    )
    parser.add_argument("repo_url", help="Git repository URL")
    parser.add_argument("branch", help="Target branch name")
    parser.add_argument("clone_dir", help="Local clone directory")
    parser.add_argument(
        "-m", "--message",
        default="update",
        help="Commit message"
    )

    args = parser.parse_args()

    result = generate_git_commands(
        args.repo_url,
        args.branch,
        args.clone_dir,
        args.message
    )

    print("\n=== Git Bash Commands ===\n")
    print(result)


if __name__ == "__main__":
    main()