# Contributing Guidelines

The following is a set of guidelines for contributing to the NGINX Ingress Operator. We really appreciate that you are considering contributing!

#### Table Of Contents

[Ask a Question](#ask-a-question)

[Getting Started](#getting-started)

[Contributing](#contributing)

[Style Guides](#style-guides)
  * [Git Style Guide](#git-style-guide)

[Code of Conduct](CODE_OF_CONDUCT.md)

## Ask a Question

To ask a question please use [Github Discussions](https://github.com/nginx/kubernetes-ingress/discussions).

You can also get help through the [NGINX Community Forum](https://community.nginx.org/).

Please reserve GitHub issues for feature requests and bugs rather than general questions.

## Getting Started

Follow our [Installation Guide](docs/installation.md) to get the NGINX Ingress Operator up and running.

Read the [documentation](https://github.com/nginx/nginx-ingress-helm-operator/tree/main/docs) .

### Project Structure

* This Operator was created the using the Helm operator-framework and supports both the open source NGINX Ingress Controller and NGINX Plus Ingress Controller. It supports the same NGINX Ingress Controller features as the NGINX Ingress Controller Helm chart.

## Contributing

### Report a Bug

To report a bug, open an issue on GitHub with the label `bug` using the available bug report issue template. Please ensure the issue has not already been reported.

### Suggest an Enhancement

To suggest an enhancement, please create an issue on GitHub with the label `enhancement` using the available feature issue template.

### Open a Pull Request

* Fork the repo, create a branch, submit a PR when your changes are tested and ready for review
* Fill in [our pull request template](.github/PULL_REQUEST_TEMPLATE.md)

> **Note**
>
> If you’d like to implement a new feature, please consider creating a feature request issue first to start a discussion about the feature.

### Issue lifecycle

* When an issue or PR is created, it will be triaged by the core development team and assigned a label to indicate the type of issue it is (bug, feature request, etc) and to determine the milestone. Please see the [Issue Lifecycle](ISSUE_LIFECYCLE.md) document for more information.

### F5 Contributor License Agreement (CLA)

F5 requires all external contributors to agree to the terms of the F5 CLA (available [here](https://github.com/f5/.github/blob/main/CLA/cla-markdown.md))
before any of their changes can be incorporated into an F5 Open Source repository.

If you have not yet agreed to the F5 CLA terms and submit a PR to this repository, a bot will prompt you to view and
agree to the F5 CLA. You will have to agree to the F5 CLA terms through a comment in the PR before any of your changes
can be merged. Your agreement signature will be safely stored by F5 and no longer be required in future PRs.

## Style Guides

### Git Style Guide

* Keep a clean, concise and meaningful git commit history on your branch, rebasing locally and squashing before submitting a PR
* Follow the guidelines of writing a good commit message as described here https://chris.beams.io/posts/git-commit/ and summarized in the next few points
    * In the subject line, use the present tense ("Add feature" not "Added feature")
    * In the subject line, use the imperative mood ("Move cursor to..." not "Moves cursor to...")
    * Limit the subject line to 72 characters or less
    * Reference issues and pull requests liberally after the subject line
    * Add more detailed description in the body of the git message (`git commit -a` to give you more space and time in your text editor to write a good message instead of `git commit -am`)
