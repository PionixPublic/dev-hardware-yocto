# Developer Guide: Collaboration Workflow for Yocto Project

## Overview

This guide outlines the branching, release, and workflow strategies for efficient collaboration on the project. The structure supports feature development, stable releases, and hotfix management while ensuring clarity and traceability.

---

## Branching Strategy

### 1. **Base Branches**
- Each major Yocto version has its own base branch:
  ```
  base/<yocto-version>
  ```
  Examples:
  - `base/kirkstone`
  - `base/hardknott`

  **Purpose:** Ongoing development and integration of features targeting a specific Yocto release.

### 2. **Feature Branches**
- Features are developed in branches created off the relevant base branch:
  ```
  feature/<yocto-version>/<feature-name>
  ```
  Examples:
  - `feature/kirkstone/add-ssh-support`
  - `feature/hardknott/improve-logging`

  **Workflow:**
  1. Develop and test in the feature branch.
  2. Open a Pull Request (PR) targeting the relevant base branch (`base/<yocto-version>`).
  3. Get code reviewed and merged.

### 3. **Release Branches**
- Stable releases are managed in release branches:
  ```
  release/<yocto-version>/<version>
  ```
  Examples:
  - `release/kirkstone/1.0`
  - `release/hardknott/2.0`

  **Purpose:** Final stabilization and bug fixing for specific releases.

### 4. **Hotfix Branches**
- Critical fixes for releases are developed in hotfix branches:
  ```
  hotfix/<yocto-version>/<release-version>/<hotfix-name>
  ```
  Examples:
  - `hotfix/kirkstone/1.0/fix-boot-error`
  - `hotfix/hardknott/2.0/resolve-dependency`

  **Workflow:**
  1. Create a hotfix branch off the corresponding release branch.
  2. After testing, merge into:
     - The release branch (`release/<yocto-version>/<version>`) for patch releases.
     - The base branch (`base/<yocto-version>`) for ongoing development.

---

## Release Workflow

### 1. **Release Candidates**
- Release candidates are pushed to the release branch:
  ```
  release/<yocto-version>/<version>-rcN
  ```
  Examples:
  - `release/kirkstone/1.0-rc1`
  - `release/kirkstone/1.0-rc2`

  **Purpose:** Testing and feedback before finalizing the release.

**Workflow for Release Candidates:**
1. Push changes to the release branch.
2. Tag the candidate:
   ```
   git tag <yocto-version>-v<version>-rcN
   ```
   Example:
   - `kirkstone-v1.0-rc1`
3. Test and review the release candidate.

### 2. **Finalizing the Release**
- When a release candidate is deemed stable:
  1. Merge the release branch into the base branch (`base/<yocto-version>`).
  2. Tag the final release:
     ```
     git tag <yocto-version>-v<version>
     ```
     Example:
     - `kirkstone-v1.0`
  3. Announce the release.

### 3. **Patch Releases**
- For updates to a released version, follow the hotfix workflow:
  - Update the release branch (`release/<yocto-version>/<version>`).
  - Tag the patch release:
    ```
    git tag <yocto-version>-v<version>.N
    ```
    Example:
    - `kirkstone-v1.0.1`

---

## Tagging Convention

- **Release Candidates:**
  ```
  <yocto-version>-v<version>-rcN
  ```
  Example: `kirkstone-v1.0-rc1`

- **Final Releases:**
  ```
  <yocto-version>-v<version>
  ```
  Example: `kirkstone-v1.0`

- **Patch Releases:**
  ```
  <yocto-version>-v<version>.N
  ```
  Example: `kirkstone-v1.0.1`

---

## Development Workflow

1. **Start a Feature:**
   - Create a branch:
     ```
     git checkout -b feature/<yocto-version>/<feature-name> base/<yocto-version>
     ```
   - Work on the feature and commit changes.

2. **Submit for Review:**
   - Push the branch:
     ```
     git push origin feature/<yocto-version>/<feature-name>
     ```
   - Open a PR against `base/<yocto-version>`.

3. **Prepare a Release:**
   - Merge all relevant features into `base/<yocto-version>`.
   - Branch for release:
     ```
     git checkout -b release/<yocto-version>/<version> base/<yocto-version>
     ```
   - Stabilize and tag release candidates.

4. **Finalizing a Release:**
   - Merge the release branch into `base/<yocto-version>`:
     ```
     git checkout base/<yocto-version>
     git merge release/<yocto-version>/<version>
     ```
   - Tag the release:
     ```
     git tag <yocto-version>-v<version>
     git push origin <yocto-version>-v<version>
     ```

5. **Hotfixing a Release:**
   - Create a branch:
     ```
     git checkout -b hotfix/<yocto-version>/<release-version>/<hotfix-name> release/<yocto-version>/<version>
     ```
   - Apply fixes and test.
   - Merge into:
     - `release/<yocto-version>/<version>`
     - `base/<yocto-version>`

---

## Collaboration Guidelines

1. **Follow Naming Conventions:**
   - Use the branch and tag formats described above.

2. **Code Reviews:**
   - All feature and hotfix branches must go through PRs and reviews.

3. **Testing:**
   - Test features thoroughly in their branches.
   - Conduct comprehensive testing for release candidates.

4. **Documentation:**
   - Document changes in commit messages and update any relevant project documentation.

---

## CI/CD Integration

- Feature branches trigger builds for the specific Yocto base to ensure compatibility.
<!-- - Release candidates undergo extended testing in CI/CD pipelines. -->
<!-- TODO : - Final releases trigger deployment processes and artifact publication. -->

## Binaries Naming convention

The following pattern should be used when we release the images to the customers:
**<product>-<type>-<hardware_variant>-<yocto_version_name>-v<version_number>-<pipeline_number>.<extension>**

Product:
- belaybox
- umwcharger
- umwcar
  
Type:
- image
- bundle
  
Hardware variant:
- raspberrypi4
- raspberrypi5
  
Yocto version name:
- kirkstone
- scarthgap
  
Version number:
- 1.0
- 1.1
  
Pipeline number: this is the number that the building pipeline has pushed the binary into Nexus. Please keep it accurate so that we can identify what pipeline has been used to build the binary

Examples:
belaybox-image-raspberrypi4-kisrkstone-v1.0-186.wic.bz2  
umwcar-bundle-raspberrypi4-kirkstone-v1.1-200-1.raucb
belaybox-bundle-raspberrypi4-kisrkstone-v1.0-186.raucb
