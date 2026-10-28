#!/bin/bash
set -e

git config user.name  "github-actions[bot]"
git config user.email "github-actions[bot]@users.noreply.github.com"

mkdir -p apps

COUNT=$(yq '.upstreams | length' config/upstreams.yml)

for i in $(seq 0 $((COUNT - 1))); do
  NAME=$(yq ".upstreams[$i].name" config/upstreams.yml)
  UPSTREAM=$(yq ".upstreams[$i].upstream" config/upstreams.yml)
  BRANCH=$(yq ".upstreams[$i].branch" config/upstreams.yml)
  TARGET="apps/${NAME}"

  echo "===== 同步 ${NAME} <- ${UPSTREAM} (${BRANCH}) ====="

  rm -rf "${TARGET}"
  git clone --depth 1 --branch "${BRANCH}" \
    "https://github.com/${UPSTREAM}.git" "${TARGET}"

  rm -rf "${TARGET}/.git"

  git add "${TARGET}"
done

if git diff --staged --quiet; then
  echo "所有软件均无更新，跳过提交"
else
  git commit -m "chore: sync upstream apps ($(date +%Y-%m-%d))"
  git push
fi
