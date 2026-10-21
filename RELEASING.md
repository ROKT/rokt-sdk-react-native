# Releasing

Releases are published to npm as `@rokt/react-native-sdk` by GitHub Actions. Nobody publishes from a
local machine.

## Release lines

| Branch              | Releases                          | npm dist-tag                                       |
| ------------------- | --------------------------------- | -------------------------------------------------- |
| `main`              | the current major                 | `latest` (`next` for a prerelease)                 |
| `maintenance/<N>.x` | patches and minors of major `<N>` | `maintenance-<N>.x`, or `latest` while it is newer |

A stable release takes `latest` only when it is newer than npm's current `latest`, so `latest` never
moves backwards. A maintenance release therefore takes `latest` until the next major ships; after
that it is published as `maintenance-<N>.x`. A release from `main` that is not newer than `latest`
fails instead of publishing. A prerelease never moves a stable tag: it is published as `next` from
`main` and as `maintenance-<N>.x-next` from a maintenance branch.

## Publishing a release

1. In Actions, run **Release – Draft** on `main` or on `maintenance/<N>.x`, and choose `patch`,
   `minor` or `major`. Major releases can only be drafted from `main`.
2. The workflow opens a `release/<version>` pull request into the branch it ran on. That pull request
   bumps `VERSION` and the `package.json` versions, and adds the `CHANGELOG.md` entry generated from
   the commit history.
3. Review the changelog and merge the pull request.
4. The `VERSION` change on the branch starts **Release – Publish**. It builds the package, runs the
   iOS and Android builds and tests, publishes the verified tarball to npm, and creates the GitHub
   release and the `<version>` tag that the podspec points to.

## Maintenance branches

- **Cutting one.** Before the first breaking change for the next major merges into `main`:
  1. Allow `maintenance/*` to deploy to the `npm-publish` environment (Settings › Environments ›
     `npm-publish` › Deployment branches). Without it, publishing from the branch fails.
  2. Create `maintenance/<N>.x` from `main`, where `<N>` is the current major, and protect it like
     `main`.
- **Fixes.** Open a pull request against the branch the fix is for. A fix that applies to both lines
  goes to each branch in its own pull request.
- **Installing.** Apps that stay on an older major pin a range, for example
  `npm install @rokt/react-native-sdk@^<N>.0.0`. The `maintenance-<N>.x` tag only exists once a
  maintenance release has shipped after the next major.
