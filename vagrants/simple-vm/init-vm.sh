#!/bin/bash
# Cloud config

ssh_pwauth: True
chpasswd:
  list: |
    root: a
    vagrant: 1
  expire: False

