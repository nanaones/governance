#/bin/bash

tbears clear
tbears start
tbears deploy governance

python -m unittest test_governance.py
