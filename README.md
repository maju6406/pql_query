[![Build Status](https://travis-ci.org/maju6406/pql_query.svg?branch=master)](https://travis-ci.org/maju6406/pql_query)

# pql_query

#### Table of Contents

1. [Description](#description)
2. [Requirements](#requirements)
3. [Usage - Configuration options and additional functionality](#usage)
4. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
5. [Getting help - Some Helpful commands](#getting-help)

## Description

This module provides the pql_query task. This task lets you run pql queries and display the results in the PE Console"

## Requirements
This module is compatible with Puppet Enterprise and Puppet Bolt.

* To run tasks with Puppet Enterprise, PE 2017.3 or later must be installed on the machine from which you are running task commands. Machines receiving task requests must be Puppet agents.

* To run tasks with Puppet Bolt, Bolt 0.5 or later must be installed on the machine from which you are running task commands. Machines receiving task requests must have SSH or WinRM services enabled. If using Bolt, the puppet agent must already installed.

## Usage

### Usage

You can also run the Puppet Task from the command line using:

```
puppet task run pql_query::run query=<value> <[--nodes, -n <node-names>] | [--query, -q <'query'>]>
```

Or using bolt:

```
bolt task run --nodes, -n <node-name> pql_query::run query=<value>
```
**NOTE** The task can take a few minutes to run.

There is 1 parameter:
* query : pql query you want to execute  
If something goes wrong, try changing single quotes to double quotes or vice versa.

The results will be shown in YAML in the console.  
The results are saved in /tmp in json and yaml formats. 
## Reference

To view the available actions and parameters, on the command line, run `puppet task show pql_query` or see the pql_query module page on the [Forge](https://forge.puppet.com/beersy/pql_query/tasks).

## Getting Help

To display help for the pql_query task, run `puppet task show pql_query::run`

To show help for the task CLI, run `puppet task run --help` or `bolt task run --help`

## Limitations
This task can only be targeted to the master node

## Release Notes/Contributors/Etc.
0.1.0 - Initial Release