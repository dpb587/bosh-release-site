# bosh-release-docs

A [Hugo](https://gohugo.io/) theme, scripts, and conventions for providing a documentation site about a BOSH release.

**Unstable** -- this is experimental while I'm trying it out in a few of my releases. Eventually it might be something which is more easily reusable by other releases. Get in touch if you're interested in helping provide feedback or improvements to help that process.


## Conventions


### Release

To provide more information about aspects of your release, include a `description` field in the following specifications. Markdown may be used to provide more meaningful hints and links.

 * jobs
 * job properties
 * link provider definitions
 * link consumer definitions
 * packages


#### Job Properties

In addition to the `description` field of a property, include an `example` field to provide a concrete value to help readers understand expected values in complex properties. Be sure to use the actual type of value and data you would expect your users to provide (do not provide a string block of YAML data).

    properties:
      my_complex_setting:
        description: This multi-level, multi-field property might be confusing.
        example:
          provider: ldap
          options:
            ca: |
              -----BEGIN CERTIFICATE-----
              ...
              -----END CERTIFICATE-----
            tls_required: true
            dn: "ou=People,dc=example,dc=com"


#### Release Notes

When cutting a new release, provide Markdown release notes alongside your finalized `releases` YAML file. This can then be shown inline to users.

    $ ls releases/openvpn
    releases/openvpn/openvpn-5.3.0.md
    releases/openvpn/openvpn-5.3.0.yml


### Documentation

Write your documentation in [Markdown](https://www.markdownguide.org/basic-syntax/) format in the `docs` directory.


#### Links

When referring to other Markdown documentation files, create links using the [`relref` shortcode](https://gohugo.io/content-management/shortcodes/#ref-and-relref) with a relative path to the documentation.

    [Sibbling File]({{< relref "sibbling-file.md#header" >}})
    [Another Doc]({{< ref "../parent-dir/sub-file.md" >}})


#### Shortcodes

Several shortcodes are provided to help embed more dynamic content into your documentation.


##### `job/ref`

Useful for getting the link to a specific job definition of a version. By default, the latest version will be used.

Parameters:

 * `job` (required) -- the release job name
 * `version` (optional; default latest) -- a specific version to reference instead of latest

Examples:

    [latest `openvpn` job]({{< job/ref job="openvpn" >}})
    [specific `openvpn` job]({{< job/ref job="openvpn" version="4.0.0" >}})


##### `note`

Useful for showing a stylized call-out message to users.

Parameters:

 * `type` (optional; default `info`) -- the style of note (supported values are: `primary`, `link`, `info`, `success`, `warning`, `danger`)
 * `title` (optional) -- for including header text in the note
 * content (required) -- message, in Markdown, which will be rendered to the user

Examples:

    {{< note >}}
      Learn more about [Architectural Decision Records](https://adr.github.io/).
    {{</ note >}}

    {{< note type="warning" title="Advanced Topic" >}}
      This is an advanced topic! Be sure you understand the [basic concepts]({{< relref "concepts.md" >}}) first.
    {{</ note >}}


##### `package/ref`

Useful for getting the link to a specific package definition of a version. By default, the latest version will be used.

Parameters:

 * `package` (required) -- the release package name
 * `version` (optional; default latest) -- a specific version to reference instead of latest

Examples:

    [latest `go` package]({{< package/ref package="go" >}})
    [specific `go` package]({{< package/ref package="go" version="0.21.0" >}})


##### `release/latest-menu`

Useful for adding a menu item listing the latest version and a link to its usage and jobs.

Example:

    {{< release/latest-menu >}}


##### `release/usage`

Useful for showing basic instructions on using a release. Shows a snippet for use in the `releases` section of a manifest and instructions for uploading via `bosh upload-release`.

Example:

    {{< release/usage >}}


## Notes

 * Hugo-based; this contains a theme for it.
 * Not the cleanest use of Hugo content concepts (e.g. release versions as sections with multiple content types within them).
 * Theme files should be cleaned up; forked from [dpb587/ssoca](https://github.com/dpb587/ssoca/tree/docs-hugo-site).
 * Documentation is segmented by major version.


## License

[MIT License](LICENSE)
