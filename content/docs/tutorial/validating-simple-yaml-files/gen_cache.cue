package site
{
	content: {
		docs: {
			tutorial: {
				"validating-simple-yaml-files": {
					page: {
						cache: {
							upload: {
								yamlBroken: "JPfCgrHnKJGzNReL/CBNdlePWYlPCacN2nUQCRkZhq8="
								"pets.cue": "EbeYlz/cmJ6hhHUqKuZ1PGSEJpyo9iN3TdVG6yHBkvE="
								yamlFixed:  "tShq9YhHmtxwgrIEqJm9eAy+NSPNayIQe1zGXYovTVc="
								yaml2:      "cOl9nKZ3zaWeN6hyr9LswrLZFqwUuZR1g4q+/LdlLFQ="
							}
							multi_step: {
								"VF40V5ROLMA8AC83MA0N99B2ONAC2P9TB1KDBAMCTFF1M24T9SPG====": '''
										e5c8c220a96c604b460a3e7d7a785b373c50ff7f917eb9cb66207e69df651316
										/home/runner
										e5c8c220a96c604b460a3e7d7a785b373c50ff7f917eb9cb66207e69df651316
										0
										$ mkdir validating-yaml-with-cue
										4773e7244599dc619f64537f8ae669dc1b7d2feeb514e5908badeda924fa1b45
										4773e7244599dc619f64537f8ae669dc1b7d2feeb514e5908badeda924fa1b45
										0
										$ cd validating-yaml-with-cue
										daa46c69f182300392d3e025b5379272aea3ef34b0bcbd436133c12029b066fe
										daa46c69f182300392d3e025b5379272aea3ef34b0bcbd436133c12029b066fe
										0
										$ cat <<EOD > charlie.yml
										name:
										  first: Charlie
										  last:  Cartwright
										species: goldfish
										age: "15"

										EOD
										$ cat <<EOD > pets.cue
										species!: "cat" | "dog"
										age?:     number

										EOD
										$ cue vet pets.cue charlie.yml
										863fbfb80017aa956eca4753e07875a5bb53ae9f4bef4575f03e8df7997f0d38
										age: conflicting values "15" and number (mismatched types string and number):
										    ./charlie.yml:5:6
										    ./pets.cue:2:11
										species: 2 errors in empty disjunction:
										species: conflicting values "cat" and "goldfish":
										    ./charlie.yml:4:10
										    ./pets.cue:1:11
										species: conflicting values "dog" and "goldfish":
										    ./charlie.yml:4:10
										    ./pets.cue:1:19
										863fbfb80017aa956eca4753e07875a5bb53ae9f4bef4575f03e8df7997f0d38
										1
										$ cat <<EOD > charlie.yml
										name:
										  first: Charlie
										  last:  Cartwright
										species: cat
										age: 15

										EOD
										$ cue vet pets.cue charlie.yml
										ee9c2f3009f337f970cef8ab73eea32ef4a3114509bf81b03402d1c5902e54cc
										ee9c2f3009f337f970cef8ab73eea32ef4a3114509bf81b03402d1c5902e54cc
										0
										$ cat <<EOD > toby.yml
										name:
										  first: Toby
										  last: Dog
										species: dog
										age: 12.5

										EOD
										$ cue vet pets.cue charlie.yml toby.yml
										94d26d7016a57cc432bb9afd29633f2e2b8516fe1e5f46b60d101752df7b32dc
										94d26d7016a57cc432bb9afd29633f2e2b8516fe1e5f46b60d101752df7b32dc
										0


										'''
							}
						}
					}
				}
			}
		}
	}
}
