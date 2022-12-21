// Copyright 2022 The CUE Authors
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

package github

import (
	"github.com/SchemaStore/schemastore/src/schemas/json"
)

// The trybot workflow.
trybot: _base.#bashWorkflow & {
	// Note: the name of this workflow is used by gerritstatusupdater as an
	// identifier in the status updates that are posted as reviews for this
	// workflows, but also as the result label key, e.g. "TryBot-Result" would
	// be the result label key for the "TryBot" workflow. Note the result label
	// key is therefore tied to the configuration of this repository.
	//
	// This name also shows up in the CI badge in the top-level README.
	name: "TryBot"

	on: {
		push: {
			branches: ["trybot/*/*", _#defaultBranch, _base.#testDefaultBranch] // do not run PR branches
		}
		pull_request: {}
	}

	jobs: {
		test: {
			"runs-on": _#linuxMachine
			steps: [
				_base.#checkoutCode & {
					// "pull_request" builds will by default use a merge commit,
					// testing the PR's HEAD merged on top of the master branch.
					// For consistency with Gerrit, avoid that merge commit entirely.
					// This doesn't affect "push" builds, which never used merge commits.
					with: ref: "${{ github.event.pull_request.head.sha }}"
				},
				json.#step & {
					name: "Install Node"
					uses: "actions/setup-node@v3"
					with: {
						"node-version": "18.9.0"
					}
				},
				_base.#installGo & {
					with: "go-version": "1.19.1"
				},

				json.#step & {
					// The latest git clean check ensures that this call is effectively
					// side effect-free. Using GOPROXY=direct ensures we don't accidentally
					// hit a stale cache in the proxy.
					name: "Ensure latest CUE"
					run: """
						GOPROXY=direct go get -d cuelang.org/go@latest
						go mod tidy
						cd play
						GOPROXY=direct go get -d cuelang.org/go@latest
						go mod tidy
						"""
				},

				_#play & {
					name: "Re-vendor play"
					run:  "./_scripts/revendorToolsInternal.bash"
				},

				// Go generate steps
				_#goGenerate & {
					name: "Regenerate"
				},
				_#goGenerate & _#play & {
					name: "Regenerate play"
				},

				// Go test steps
				_#goTest & {
					name: "Test"
				},
				_#goTest & _#play & {
					name: "Test play"
				},

				// go mod tidy
				_#modTidy & {
					name: "Check module is tidy"
				},
				_#modTidy & _#play & {
					name: "Check play module is tidy"
				},

				_#dist,

				json.#step & {
					name: "Verify commit is clean"
					run: """
						test -z "$(git status --porcelain)" || (git status; git diff; false)
						"""
				},

				// Note we intentially run this after the porcelain check because
				// this step intentionally updates the play/go.{mod,sum}. This step
				// purely exists to exercise this code path and determine whether it
				// passes/fails.
				_#tipDist,
			]
		}
	}

	_#play: json.#step & {
		"working-directory": "./play"
	}

	_#goGenerate: json.#step & {
		name: string
		run:  "go generate ./..."
	}

	_#goTest: json.#step & {
		name: string
		run:  "go test ./..."
	}

	_#modTidy: json.#step & {
		name: string
		run:  "go mod tidy"
	}
}

_#dist: json.#step & {
	name: *"Dist" | string
	run:  "./build.bash"
}

_#tipDist: _#dist & {
	name: "Tip dist"
	env: BRANCH: "tip"
}