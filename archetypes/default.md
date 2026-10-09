---
title: "{{ replace .File.ContentBaseName "-" " " | title }}"
description: ""
date: {{ .Date }}
draft: true
translationKey: "{{ .File.ContentBaseName }}"
tags: []
# tested: ["Fedora 44", "Ansible 2.18"]  # optional: shows "Tested on ..." under the title
# showUpdated: false                    # optional: hide the git "Updated" date (e.g. after typo-only fixes)
---
