# HOW TO MAKE A RELEASE


```
git tag  prepare-v1.1.1; git push --tags
git tag -d prepare-v1.1.1; git push --delete origin prepare-v1.1.1 || git push origin --delete v1.x
```

```shell
TAG_NAME=prepare-v1.1.1 GITHUB_TOKEN=tok GITHUB_REPOSITORY=cdelgehier/learning_golang make release
```