#!/bin/bash
set -e -u -o pipefail

CURRENT_DIR="$(cd "$(dirname "$0")" && pwd -P)"
REPOSITORY_ROOT="$(cd "${CURRENT_DIR}/.." && pwd -P)"

ARCHIVE_FILE="${REPOSITORY_ROOT}/${APP_NAME-myapp}-${TAG_NAME-NO_TAGNAME}.tar.gz"

if [ ! -f "${ARCHIVE_FILE}" ]
then
  echo "* Generating release archive"

  TMP_DIR="$(mktemp -d)"
  ARCHIVE_BASENAME="myapp-${TAG_NAME-NO_TAGNAME}"
  TMP_WORKINGDIR="${TMP_DIR}/${ARCHIVE_BASENAME}"

  rm -f "${ARCHIVE_FILE}"
  cd "${TMP_DIR}" || exit 1
  cp -r "${REPOSITORY_ROOT}" "${TMP_WORKINGDIR}"


  # Exclusions avoid not needed technical files to be present in the final archive
  tar -cz \
    --exclude='NOTES.md' \
    --exclude='.gitignore' \
    --exclude='tools' \
    --exclude='.git' \
    --exclude='.github' \
    --exclude='Makefile' \
    --exclude='RELEASE.md' \
    -f "${ARCHIVE_FILE}" "${ARCHIVE_BASENAME}"

  echo "* Done !"
  echo
  echo
  echo "**** Release file is ready in ${ARCHIVE_FILE} ****"
  echo
  echo
  echo
else
  echo "== File ${ARCHIVE_FILE} found: nothing to build."
fi
