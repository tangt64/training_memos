#!/bin/bash
tr A-Z a-z |
sort |
uniq -c |
sort -k1,1nr
