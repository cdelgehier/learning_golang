#!/bin/bash
set -x -e -u -o pipefail

CURRENT_DIR="$(cd "$(dirname "$0")" && pwd -P)"
REPOSITORY_ROOT="$(cd "${CURRENT_DIR}/.." && pwd -P)"

## Check requirements
# Git CLI
: "${1?"ERROR: First argument empty. Please provide a valid tag pointing to the current HEAD as argument. Exiting."}"
command -v git >/dev/null 2>&1 || { echo "ERROR: Cannot find the 'git' command line which is required. Exiting." && exit 1;}
# Hub CLI
: "${GITHUB_REPOSITORY?"ERROR: Variable GITHUB_REPOSITORY is empty. Please provide it to allow the 'hub' CLI to work as expected. Exiting."}"
GITHUB_USER="${GITHUB_REPOSITORY%/*}"
GITHUB_PROJECT="${GITHUB_REPOSITORY#*/}"
: "${GITHUB_TOKEN?"ERROR: Variable GITHUB_TOKEN is empty. Please provide it to allow the 'hub' CLI to work as expected. Exiting."}"
command -v hub >/dev/null 2>&1 || { echo "ERROR: Cannot find the 'hub' command line which is required. Exiting." && exit 1;}

## Check that the tag provided as argument matches the expected pattern
[[ "${1}" =~ prepare-v([0-9]+)\.([0-9]+)\.([0-9]+) ]] || \
  { echo "ERROR: Provided argument(${1}) does not match the expected pattern ('vX.Y.Z' where X, Y and Z are integer digits). Exiting." && exit 1;}
PREPARE_TAG="${1}"
FINALE_TAG="${1:8}"
BRANCH="${FINALE_TAG%%\.*}.x" # Branch name is extracted from the major version
echo "== Provided tag '${PREPARE_TAG}' is valid. Preparing a release with the tag '${FINALE_TAG}' on the branch '${BRANCH}'..."

## Generate changelog between current HEAD and previous tag
PREVIOUS_TAG="$(git describe --tags --abbrev=0 HEAD~1)"
[ -n "${PREVIOUS_TAG}" ] || PREVIOUS_TAG="$(git rev-list --max-parents=0 HEAD)"
: "${PREVIOUS_TAG?"ERROR: Could not determine a reference commit neither a previous tag or the oldest commit. Exiting"}"

CURRENT_COMMIT="$(git rev-parse --verify HEAD)"
: "${CURRENT_COMMIT?"ERROR: Could not retrieve neither a previous tag or the oldest commit. Exiting"}"

echo "== Preparing Changelog from ref. ${PREVIOUS_TAG} to current ref. ${CURRENT_COMMIT}..."

# The list of commit from the history is processed with the following:
# - Removing lines with the string "BUMP" (commit tags)
# - Sorting and removing doublons
# - Replacing double spaces by simple spaces
changelog="$(git log "${PREVIOUS_TAG}..${CURRENT_COMMIT}" --pretty="format:- %s" | cat \
  | grep -v "^- BUMP" \
  | sort | uniq \
  | sed 's/  / /g' \
)"

echo "== Changelog retrieved: preparing release commit by writing and commiting files..."
## Prepend changelog message in the changelog file
CHANGELOG_FILE="${REPOSITORY_ROOT}/CHANGELOG.md"
sed -i '/# CHANGELOG/r'<(printf "\n## %s\n\n### customer-skeleton\n\n%s\n" "${FINALE_TAG}" "${changelog}") "${CHANGELOG_FILE}"

## Write expected version in the VERSION file
VERSION_FILE="${REPOSITORY_ROOT}/VERSION"
echo "${FINALE_TAG}" > "${VERSION_FILE}"

## Commit and push changes Changes
git config --local user.name "CI"
git config --local user.email "ci@worker.local"
git add "${CHANGELOG_FILE}" "${VERSION_FILE}"
git commit -m "BUMP: Update VERSION and CHANGELOG.md for ${FINALE_TAG}"

echo "== Release commit ready. Pushing changes to repository and creating release..."
git checkout -b "${BRANCH}"
git push origin "HEAD:${BRANCH}"

## Remove "prepare" tag
git push --delete origin "${PREPARE_TAG}"

## Generate a new archive including release's changes with the finale tag name
# Note that the variable TAG_NAME is overriden to use the finale tag (and not the "prepare-..." tag)
TAG_NAME="${FINALE_TAG}" bash "${CURRENT_DIR}/build.sh"
# Retrieve the name of this new archive with the same "TAG_NAME overriding" technique
ARCHIVE_FILE="$(TAG_NAME="${FINALE_TAG}" get_archive_path)"

## Create a Release (along with a tag) in Github from the current commit
RELEASE_COMMIT="$(git rev-parse --verify HEAD)"
printf "%s\n\n## %s\n\n%s\n" "${FINALE_TAG}" "Changes since ${PREVIOUS_TAG}" "${changelog}" \
  | hub release create --attach="${ARCHIVE_FILE}" --file=- --commitish "${RELEASE_COMMIT}" "${FINALE_TAG}"

echo "== Release finished successfully"
exit 0
