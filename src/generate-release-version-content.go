package main

import (
	"bytes"
	"fmt"
	"io/ioutil"
	"os"
	"os/exec"
	"path"
	"strconv"
	"strings"

	"gopkg.in/yaml.v2"
)

func main() {
	versionFile := os.Args[1]
	contentDir := os.Args[2]

	versionBytes, err := ioutil.ReadFile(versionFile)
	if err != nil {
		panic(err)
	}

	var raw map[string]interface{}
	err = yaml.Unmarshal(versionBytes, &raw)
	if err != nil {
		panic(err)
	}

	releaseName := raw["name"].(string)
	releaseVersion := raw["version"].(string)
	releaseCommittish := raw["commit_hash"].(string)

	{ // choose a commit or tag as the best way to reference the release
		optimisticTag := fmt.Sprintf("v%s", releaseVersion)

		cmdStdout := bytes.NewBuffer(nil)
		cmd := exec.Command("git", "rev-list", "-n1", optimisticTag)
		cmd.Stdout = cmdStdout

		cmd.Run() // ignore err; best effort

		if strings.HasPrefix(cmdStdout.String(), releaseCommittish) {
			releaseCommittish = optimisticTag
		}
	}

	for _, job := range raw["jobs"].([]interface{}) {
		hugoContent := map[string]interface{}{}
		hugoContent["boshReleaseName"] = releaseName
		hugoContent["boshReleaseVersion"] = releaseVersion
		hugoContent["boshReleaseCommittish"] = releaseCommittish
		hugoContent["releases"] = []string{fmt.Sprintf("v%s", releaseVersion)}

		jobName := job.(map[interface{}]interface{})["name"].(string)
		hugoContent["title"] = jobName

		jobSpecBytes, err := ioutil.ReadFile(path.Join("jobs", jobName, "spec"))
		if err != nil {
			panic(err)
		}

		hugoContent["boshReleaseJobSpecRaw"] = string(jobSpecBytes)

		var jobSpec map[string]interface{}
		err = yaml.Unmarshal(jobSpecBytes, &jobSpec)
		if err != nil {
			panic(err)
		}

		// hugo does not know how to convert an object to yaml; marshal it here
		for property, propertySpec := range jobSpec["properties"].(map[interface{}]interface{}) {
			propertySpecMap := propertySpec.(map[interface{}]interface{})

			for _, field := range []string{"default", "example"} {
				if v, found := propertySpecMap[field]; found {
					rawBytes, err := yaml.Marshal(v)
					if err != nil {
						panic(err)
					}

					propertySpecMap[fmt.Sprintf("_hugo_%s_raw", field)] = string(rawBytes)
				}
			}

			jobSpec["properties"].(map[interface{}]interface{})[property] = propertySpecMap
		}

		hugoContent["boshReleaseJobSpec"] = jobSpec

		hugoContentBytes, err := yaml.Marshal(hugoContent)
		if err != nil {
			panic(err)
		}

		contentPath := path.Join(contentDir, "jobs", jobName, fmt.Sprintf("v%s.md", releaseVersion))

		err = os.MkdirAll(path.Dir(contentPath), 0755)
		if err != nil {
			panic(err)
		}

		err = ioutil.WriteFile(contentPath, []byte(string(fmt.Sprintf("---\n%s---\n", hugoContentBytes))), 0744)
		if err != nil {
			panic(err)
		}
	}

	for _, package_ := range raw["packages"].([]interface{}) {
		hugoContent := map[string]interface{}{}
		hugoContent["boshReleaseName"] = releaseName
		hugoContent["boshReleaseVersion"] = releaseVersion
		hugoContent["boshReleaseCommittish"] = releaseCommittish
		hugoContent["releases"] = []string{fmt.Sprintf("v%s", releaseVersion)}

		packageName := package_.(map[interface{}]interface{})["name"].(string)
		hugoContent["title"] = packageName

		if _, err := os.Stat(path.Join("packages", packageName, "spec.lock")); err == nil {
			// TODO; generate a semi-useful spec?
		} else {
			packageSpecBytes, err := ioutil.ReadFile(path.Join("packages", packageName, "spec"))
			if err != nil {
				panic(err)
			}

			hugoContent["boshReleasePackageSpecRaw"] = string(packageSpecBytes)

			var packageSpec map[string]interface{}
			err = yaml.Unmarshal(packageSpecBytes, &packageSpec)
			if err != nil {
				panic(err)
			}

			hugoContent["boshReleasePackageSpec"] = packageSpec
		}

		hugoContentBytes, err := yaml.Marshal(hugoContent)
		if err != nil {
			panic(err)
		}

		contentPath := path.Join(contentDir, "packages", packageName, fmt.Sprintf("v%s.md", releaseVersion))

		err = os.MkdirAll(path.Dir(contentPath), 0755)
		if err != nil {
			panic(err)
		}

		err = ioutil.WriteFile(contentPath, []byte(string(fmt.Sprintf("---\n%s---\n", hugoContentBytes))), 0744)
		if err != nil {
			panic(err)
		}
	}

	hugoContent := map[string]interface{}{}
	hugoContent["boshReleaseName"] = releaseName
	hugoContent["boshReleaseVersion"] = releaseVersion
	hugoContent["boshReleaseCommittish"] = releaseCommittish
	hugoContent["boshReleaseSpecRaw"] = string(versionBytes)
	hugoContent["boshReleaseSpec"] = raw
	hugoContent["title"] = fmt.Sprintf("v%s", releaseVersion)

	weight := ""
	versionSplit := strings.SplitN(releaseVersion, ".", 4)
	for i := range []int{0, 1, 2} {
		if i <= len(versionSplit)-1 {
			weight += fmt.Sprintf("%3s", versionSplit[i])
		} else {
			weight += "   "
		}
	}

	hugoContent["weight"], err = strconv.Atoi(strings.Replace(weight, " ", "0", -1))
	if err != nil {
		panic(err)
	}

	hugoContentBytes, err := yaml.Marshal(hugoContent)
	if err != nil {
		panic(err)
	}

	contentPath := path.Join(contentDir, "releases", fmt.Sprintf("v%s", releaseVersion), "_index.md")

	err = os.MkdirAll(path.Dir(contentPath), 0755)
	if err != nil {
		panic(err)
	}

	err = ioutil.WriteFile(contentPath, []byte(string(fmt.Sprintf("---\n%s---\n", hugoContentBytes))), 0744)
	if err != nil {
		panic(err)
	}
}
