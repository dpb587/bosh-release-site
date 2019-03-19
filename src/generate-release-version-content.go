package main

import (
	"fmt"
	"io/ioutil"
	"os"
	"path"

	"gopkg.in/yaml.v2"
)

func main() {
	versionFile := os.Args[1]
	outputDir := os.Args[2]

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

	for _, job := range raw["jobs"].([]interface{}) {
		hugoContent := map[string]interface{}{}
		hugoContent["type"] = "bosh-release-job"
		hugoContent["bosh_release_name"] = releaseName
		hugoContent["bosh_release_version"] = releaseVersion

		jobName := job.(map[interface{}]interface{})["name"].(string)
		hugoContent["title"] = jobName

		jobSpecBytes, err := ioutil.ReadFile(path.Join("jobs", jobName, "spec"))
		if err != nil {
			panic(err)
		}

		hugoContent["bosh_release_job_spec_raw"] = string(jobSpecBytes)

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

		hugoContent["bosh_release_job_spec"] = jobSpec

		hugoContentBytes, err := yaml.Marshal(hugoContent)
		if err != nil {
			panic(err)
		}

		err = ioutil.WriteFile(path.Join(outputDir, fmt.Sprintf("%s-job.md", jobName)), []byte(string(fmt.Sprintf("---\n%s---\n", hugoContentBytes))), 0744)
		if err != nil {
			panic(err)
		}
	}

	for _, package_ := range raw["packages"].([]interface{}) {
		hugoContent := map[string]interface{}{}
		hugoContent["type"] = "bosh-release-package"
		hugoContent["bosh_release_name"] = releaseName
		hugoContent["bosh_release_version"] = releaseVersion

		packageName := package_.(map[interface{}]interface{})["name"].(string)
		hugoContent["title"] = packageName

		packageSpecBytes, err := ioutil.ReadFile(path.Join("packages", packageName, "spec"))
		if err != nil {
			panic(err)
		}

		hugoContent["bosh_release_package_spec_raw"] = string(packageSpecBytes)

		var packageSpec map[string]interface{}
		err = yaml.Unmarshal(packageSpecBytes, &packageSpec)
		if err != nil {
			panic(err)
		}

		hugoContent["bosh_release_package_spec"] = packageSpec

		hugoContentBytes, err := yaml.Marshal(hugoContent)
		if err != nil {
			panic(err)
		}

		err = ioutil.WriteFile(path.Join(outputDir, fmt.Sprintf("%s-package.md", packageName)), []byte(string(fmt.Sprintf("---\n%s---\n", hugoContentBytes))), 0744)
		if err != nil {
			panic(err)
		}
	}
}
