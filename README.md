Governance SCORE APIs
=====================

This document describes APIs that Governance SCORE provides.


# Overview

* Governance SCORE is a built-in SCORE that manages adjustable characteristics of ICON network.
* Address: cx0000000000000000000000000000000000000001

# Value Types

By default, Values in all JSON-RPC messages are in string form.
The most commonly used Value types are as follows.

| Value Type | Description | Example |
|:---------- |:------------|:--------|
| <a id="T_ADDR_EOA">T\_ADDR\_EOA</a> | "hx" + 40 digits HEX string | hxbe258ceb872e08851f1f59694dac2558708ece11 |
| <a id="T_ADDR_SCORE">T\_ADDR\_SCORE</a> | "cx" + 40 digits HEX string | cxb0776ee37f5b45bfaea8cff1d8232fbb6122ec32 |
| <a id="T_HASH">T\_HASH</a> | "0x" + 64 digits HEX string | 0xc71303ef8543d04b5dc1ba6579132b143087c68db1b2168786408fcbce568238 |
| <a id="T_INT">T\_INT</a> | "0x" + lowercase HEX string | 0xa |
| <a id="T_IMPORT_STMT">T\_IMPORT\_STMT</a> | Import statement string| "{'json': [],'os': ['path'],'base.exception': ['ExceptionCode','RevertException']}" |
| <a id="T_BIN_DATA">T\_BIN\_DATA</a> | "0x" + lowercase HEX string (the length of string should be even) | 0x34b2 |
| <a id="T_SIG">T\_SIG</a> | base64 encoded string | VAia7YZ2Ji6igKWzjR2YsGa2m53nKPrfK7uXYW78QLE+ATehAVZPC40szvAiA6NEU5gCYB4c4qaQzqDh2ugcHgA= |

## Import statement
### Grammar
import_stmt: "{" import_element ("," import_element)* "}" <br>
import_element: (import_name | import_from) <br>
import_name:  dotted_name ": []" <br>
Import_from:  dotted_name ": [" dotted_names "]" <br>
dotted_names: dotted_name ("," dotted_name) * <br>
dotted_name: "'"NAME ("." NAME)*"'" <br>
NAME: Not an empty string

### Exmaples
| python import | import statement |
|:------------- |:-----------------|
|import json | { 'json' : [] } |
|from json import * |{ 'json' : [] } |
|from os import path | { 'os' : ['path'] } |
|from base.exception import ExceptionCode, RevertException | { 'base.exception' : ['ExceptionCode', 'RevertException'] } |
|import json <br> from os import path <br> from base.exception import ExceptionCode, RevertException <br> | { 'json' : [], 'os' : ['path'], 'base.exception' : ['ExceptionCode', 'RevertException'] } |

# Methods List

* Query methods
    * [getScoreStatus](#getscorestatus)
    * [getStepPrice](#getstepprice)
    * [getStepCosts](#getstepcosts)
    * [getMaxStepLimit](#getmaxsteplimit)
    * [isDeployer](#isdeployer)
    * [isInScoreBlackList](#isinscoreblacklist)
    * [getVersion](#getVersion)
    * [isInImportWhiteList](#isinimportwhitelist)
    * [getServiceConfig](#getserviceconfig)
    * [getRevision](#getrevision)
* Invoke methods
    * [acceptScore](#acceptscore)
    * [rejectScore](#rejectscore)
    * [addAuditor](#addauditor)
    * [removeAuditor](#removeauditor)
    * [setStepPrice](#setstepprice)
    * [setStepCost](#setstepcost)
    * [setMaxStepLimit](#setmaxsteplimit)
    * [addDeployer](#adddeployer)
    * [removeDeployer](#removedeployer)
    * [addToScoreBlackList](#addtoscoreblacklist)
    * [removeFromScoreBlackList](#removefromscoreblacklist)
    * [addImportWhiteList](#addimportwhitelist)
    * [removeImportWhiteList](#removeimportwhitelist)
    * [updateServiceConfig](#updateserviceconfig)
    * [setRevision](#setrevision)
* Eventlog
    * [Accepted](#accepted)
    * [Rejected](#rejected)
    * [StepPriceChanged](#steppricechanged)
    * [StepCostChanged](#stepcostchanged)
    * [MaxStepLimitChanged](#maxsteplimitchanged)
    * [AddImportWhiteListLog](#addimportwhitelistlog)
    * [RemoveImportWhiteListLog](#removeimportwhitelistlog)
    * [UpdateServiceConfigLog](#updateserviceconfiglog)

# Query Methods

Query method does not change state. Read-only.

## getScoreStatus

* Queries the current status of the given SCORE.
* This tells the status of the SCORE of given address.
* `current` is the installed and running SCORE instance, while `next` is the SCORE code that has been requested to deploy or update, but not installed yet.

### Parameters

| Key | Value Type | Description |
|:----|:-----------|-----|
| address | [T\_ADDR\_SCORE](#T_ADDR_SCORE) | SCORE address to query |

### Examples

#### Request

```json
{
    "jsonrpc": "2.0",
    "id": 1234,
    "method": "icx_call",
    "params": {
        "from": "hxb0776ee37f5b45bfaea8cff1d8232fbb6122ec32", // optional
        "to": "cx0000000000000000000000000000000000000001",
        "dataType": "call",
        "data": {
            "method": "getScoreStatus",
            "params": {
                "address": "cxb0776ee37f5b45bfaea8cff1d8232fbb6122ec32"
            }
        }
    }
}
```

#### Response: SCORE install case

```json
// Response - install requested: under auditing
{
    "jsonrpc": "2.0",
    "id": 1234,
    "result": {
        "next": {
            "status": "pending",
            "deployTxHash": "0xe0f6dc6607aa9b5550cd1e6d57549f67fe9718654cde15258922d0f88ff58b27"
        }
    }
}
```

```json
// Response - audit completed: accepted
{
    "jsonrpc": "2.0",
    "id": 1234,
    "result": {
        "current": {
            "status": "active",
            "deployTxHash": "0xe0f6dc6607aa9b5550cd1e6d57549f67fe9718654cde15258922d0f88ff58b27",
            "auditTxHash": "0x644dd57fbb65b49a49bcaf5e7685e01d53dc321f1cfb7dbbf8f4306265745292"
        }
    }
}
```

```json
// Response - audit completed: rejected
{
    "jsonrpc": "2.0",
    "id": 1234,
    "result": {
        "next": {
            "status": "rejected",
            "deployTxHash": "0xe0f6dc6607aa9b5550cd1e6d57549f67fe9718654cde15258922d0f88ff58b27",
            "auditTxHash": "0x644dd57fbb65b49a49bcaf5e7685e01d53dc321f1cfb7dbbf8f4306265745292"
        }
    }
}
```

#### Response: SCORE update case

```json
// Response - update requested: under auditing
{
    "jsonrpc": "2.0",
    "id": 1234,
    "result": {
        "current": {
            "status": "active", // or "inactive"
            "deployTxHash": "0xe0f6dc6607aa9b5550cd1e6d57549f67fe9718654cde15258922d0f88ff58b207",
            "auditTxHash": "0x644dd57fbb65b49a49bcaf5e7685e01d53dc321f1cfb7dbbf8f4306265745292"
        },
        "next": {
            "status": "pending",
            "deployTxHash": "0xe0f6dc6607aa9b5550cd1e6d57549f67fe9718654cde15258922d0f88ff58b207"
        }
    }
}
```

```json
// Response - update requested, audit completed: rejected
{
    "jsonrpc": "2.0",
    "id": 1234,
    "result": {
        "current": {
            "status": "active", // or "inactive"
            "deployTxHash": "0xe0f6dc6607aa9b5550cd1e6d57549f67fe9718654cde15258922d0f88ff58b27",
            "auditTxHash": "0x644dd57fbb65b49a49bcaf5e7685e01d53dc321f1cfb7dbbf8f4306265745292"
        },
        "next": {
            "status": "rejected",
            "deployTxHash": "0xe0f6dc6607aa9b5550cd1e6d57549f67fe9718654cde15258922d0f88ff58b27",
            "auditTxHash": "0x644dd57fbb65b49a49bcaf5e7685e01d53dc321f1cfb7dbbf8f4306265745292"
        }
    }
}
```

#### Response: error case

```json
{
    "jsonrpc": "2.0",
    "id": 1234,
    "error": {
        "code": -32062,
        "message": "SCORE not found"
    }
}
```

## getStepPrice

* Returns the current step price in loop.

### Parameters

None

### Returns

`T_INT` - integer of the current step price in loop (1 ICX == 10^18 loop).

### Examples

#### Request

```json
{
    "jsonrpc": "2.0",
    "id": 1234,
    "method": "icx_call",
    "params": {
        "from": "hxb0776ee37f5b45bfaea8cff1d8232fbb6122ec32", // optional
        "to": "cx0000000000000000000000000000000000000001",
        "dataType": "call",
        "data": {
            "method": "getStepPrice"
        }
    }
}
```

#### Response

```json
{
    "jsonrpc": "2.0",
    "id": 1234,
    "result": "0xe8d4a51000" // 1000000000000
}
```

## getStepCosts

* Returns a table of the step costs for each actions.

### Parameters

None

### Returns

`T_DICT` - a dict:  key - camel-cased action strings, value - step costs in integer

### Examples

#### Request

```json
{
    "jsonrpc": "2.0",
    "id": 1234,
    "method": "icx_call",
    "params": {
        "from": "hxb0776ee37f5b45bfaea8cff1d8232fbb6122ec32", // optional
        "to": "cx0000000000000000000000000000000000000001",
        "dataType": "call",
        "data": {
            "method": "getStepCosts"
        }
    }
}
```

#### Response

```json
{
    "jsonrpc": "2.0",
    "id": 1234,
    "result": {
        "default": "0xfa0",
        "contractCall": "0x5dc",
        "contractCreate": "0x4e20",
        "contractUpdate": "0x1f40",
        "contractDestruct": "-0x1b58",
        "contractSet": "0x3e8",
        "set": "0x14",
        "replace": "0x5",
        "delete": "-0xf",
        "input": "0x14",
        "eventLog": "0xa"
    }
}
```

## getMaxStepLimit

* Returns the maximum step limit value that any SCORE execution should be bounded by.

### Parameters

| Key | Value Type | Description |
|:----|:-----------|-----|
| contextType | string | 'invoke' for sendTransaction, 'query' for call |

### Returns

`T_INT` - integer of the maximum step limit

### Examples

#### Request

```json
{
    "jsonrpc": "2.0",
    "id": 1234,
    "method": "icx_call",
    "params": {
        "from": "hxb0776ee37f5b45bfaea8cff1d8232fbb6122ec32", // optional
        "to": "cx0000000000000000000000000000000000000001",
        "dataType": "call",
        "data": {
            "method": "getMaxStepLimit",
            "params": {
                "contextType": "invoke"
            }
        }
    }
}
```

#### Response

```json
{
    "jsonrpc": "2.0",
    "id": 1234,
    "result": "0x4000000"
}
```

## isDeployer

* Returns True if the given address can deploy SCORE.

### Parameters

| Key | Value Type | Description |
|:----|:-----------|-----|
| address | [T\_ADDR\_EOA](#T_ADDR_EOA) | EOA address to query |

### Returns

`T_INT` - "0x1" if the address is in the deployer list, otherwise "0x0"

### Examples

#### Request

```json
{
    "jsonrpc": "2.0",
    "id": 1234,
    "method": "icx_call",
    "params": {
        "from": "hxb0776ee37f5b45bfaea8cff1d8232fbb6122ec32", // optional
        "to": "cx0000000000000000000000000000000000000001",
        "dataType": "call",
        "data": {
            "method": "isDeployer",
            "params": {
                "address": "hxb0776ee37f5b45bfaea8cff1d8232fbb6122ec32"
            }
        }
    }
}
```

#### Response

```json
{
    "jsonrpc": "2.0",
    "id": 1234,
    "result": "0x1"
}
```

## isInScoreBlackList

* Returns "0x1" if the given address is in the deployer list.

### Parameters

| Key | Value Type | Description |
|:----|:-----------|-----|
| address | [T\_ADDR\_SCORE](#T_ADDR_SCORE) | SCORE address to query |

### Returns

`T_INT` - "0x1" if the SCORE address is in the black list, otherwise "0x0"

### Examples

#### Request

```json
{
    "jsonrpc": "2.0",
    "id": 1234,
    "method": "icx_call",
    "params": {
        "from": "hxb0776ee37f5b45bfaea8cff1d8232fbb6122ec32", // optional
        "to": "cx0000000000000000000000000000000000000001",
        "dataType": "call",
        "data": {
            "method": "isInScoreBlackList",
            "params": {
                "address": "cxb0776ee37f5b45bfaea8cff1d8232fbb6122ec32"
            }
        }
    }
}
```

#### Response

```json
{
    "jsonrpc": "2.0",
    "id": 1234,
    "result": "0x1"
}
```



## getVersion

- Returns the version of Governance SCORE

### Returns

`T_STR` - version string

### Examples

#### Request

```json
{
    "jsonrpc": "2.0",
    "id": 1234,
    "method": "icx_call",
    "params": {
        "from": "hxb0776ee37f5b45bfaea8cff1d8232fbb6122ec32", // optional
        "to": "cx0000000000000000000000000000000000000001",
        "dataType": "call",
        "data": {
            "method": "getVersion"
        }
    }
}
```

#### Response

```json
{
    "jsonrpc": "2.0",
    "id": 1234,
    "result": "0.0.0"
}
```

## isInImportWhiteList

* Returns True if import statement is in the import white list.

### Parameters

| Key | Value Type | Description |
|:----|:-----------|-----|
| importStmt | [T\_IMPORT\_STMT](#T_IMPORT_STMT) | Import statement |

### Returns

`T_INT` - "0x1" if the import statement is in the import white list, otherwise "0x0"

### Examples

#### Request

```json
{
    "jsonrpc": "2.0",
    "id": 1234,
    "method": "icx_call",
    "params": {
        "from": "hxb0776ee37f5b45bfaea8cff1d8232fbb6122ec32", // optional
        "to": "cx0000000000000000000000000000000000000001",
        "dataType": "call",
        "data": {
            "method": "isInImportWhiteList",
            "params": {
                "importStmt": "{'json': [],'os': ['path'],'base.exception': ['ExceptionCode','RevertException']}"
            }
        }
    }
}
```

#### Response

```json
{
    "jsonrpc": "2.0",
    "id": 1234,
    "result": "0x1"
}
```

## getServiceConfig

* Returns table about server config.

### Parameters

| Key | Value Type | Description |
|:----|:-----------|-----|

### Examples

#### Request

```json
{
    "jsonrpc": "2.0",
    "id": 1234,
    "method": "icx_call",
    "params": {
        "from": "hxb0776ee37f5b45bfaea8cff1d8232fbb6122ec32", // optional
        "to": "cx0000000000000000000000000000000000000001",
        "dataType": "call",
        "data": {
            "method": "getServiceConfig",
            "params": {}
        }
    }
}
```

#### Response

```json
{
    "jsonrpc": "2.0",
    "id": 1234,
    "result": "{'fee': '0x1', 'audit': '0x0', 'deployerWhiteList': '0x1', 'scorePackageValidator': '0x0'}"
}
```

## getRevision

* Returns info about revision.

### Parameters

| Key | Value Type | Description |
|:----|:-----------|-----|

### Examples

#### Request

```json
{
    "jsonrpc": "2.0",
    "id": 1234,
    "method": "icx_call",
    "params": {
        "from": "hxb0776ee37f5b45bfaea8cff1d8232fbb6122ec32", // optional
        "to": "cx0000000000000000000000000000000000000001",
        "dataType": "call",
        "data": {
            "method": "getRevision",
            "params": {}
        }
    }
}
```

#### Response

```json
{
    "jsonrpc": "2.0",
    "id": 1234,
    "result": "{'code': '1', 'name': '1.1.0'}"
}
```


# Invoke Methods

Invoke method can initiate state transition.

## acceptScore

* Accepts SCORE deployment request.
* This method can be invoked only from the addresses that are in the auditor list.
* The accepted SCORE will be executing from the next block.

### Parameters

| Key | Value Type | Description |
|:----|:-----------|-----|
| txHash | [T\_HASH](#T_HASH) | Transaction hash of the SCORE deploy transaction. |

### Examples

#### Request

```json
{
    "jsonrpc": "2.0",
    "id": 1234,
    "method": "icx_sendTransaction",
    "params": {
        "version": "0x3",
        "from": "hxbe258ceb872e08851f1f59694dac2558708ece11",
        "to": "cx0000000000000000000000000000000000000001",
        "stepLimit": "0x12345",
        "timestamp": "0x563a6cf330136",
        "nonce": "0x1",
        "signature": "VAia7YZ2Ji6igKWzjR2YsGa2m53nKPrfK7uXYW78QLE+ATehAVZPC40szvAiA6NEU5gCYB4c4qaQzqDh2ugcHgA=",
        "dataType": "call",
        "data": {
            "method": "acceptScore",
            "params": {
                "txHash": "0xb903239f8543d04b5dc1ba6579132b143087c68db1b2168786408fcbce568238"
            }
        }
    }
}
```

## rejectScore

* Rejects SCORE deployment request.
* This can be invoked only from the addresses that are in the auditor list.

### Parameters

| Key | Value Type | Description |
|:----|:-----------|-----|
| txHash | [T\_HASH](#T_HASH) | Transaction hash of the SCORE deploy request. |
| reason | T\_TEXT | Reason for rejecting |

### Examples

#### Request

```json
{
    "jsonrpc": "2.0",
    "id": 1234,
    "method": "icx_sendTransaction",
    "params": {
        "version": "0x3",
        "from": "hxbe258ceb872e08851f1f59694dac2558708ece11",
        "to": "cx0000000000000000000000000000000000000001",
        "stepLimit": "0x12345",
        "timestamp": "0x563a6cf330136",
        "nonce": "0x1",
        "signature": "VAia7YZ2Ji6igKWzjR2YsGa2m53nKPrfK7uXYW78QLE+ATehAVZPC40szvAiA6NEU5gCYB4c4qaQzqDh2ugcHgA=",
        "dataType": "call",
        "data": {
            "method": "rejectScore",
            "params": {
                "txHash": "0xb903239f8543d04b5dc1ba6579132b143087c68db1b2168786408fcbce568238",
                "reason": "SCORE cannot use network api"
            }
        }
    }
}
```

## addAuditor

* Adds a new address to the auditor list.
* Only the addresses registered in the auditor list can call `acceptScore` and `rejectScore`.
* Only the owner of the Governance SCORE can call this function.

### Parameters

| Key | Value Type | Description |
|:----|:-----------|-----|
| address | [T\_ADDR\_EOA](#T_ADDR_EOA) | New EOA address that will be added to the auditor list |

### Examples

#### Request

```json
{
    "jsonrpc": "2.0",
    "id": 1234,
    "method": "icx_sendTransaction",
    "params": {
        "version": "0x3",
        "from": "hxbe258ceb872e08851f1f59694dac2558708ece11", // owner address
        "to": "cx0000000000000000000000000000000000000001",
        "stepLimit": "0x12345",
        "timestamp": "0x563a6cf330136",
        "nonce": "0x1",
        "signature": "VAia7YZ2Ji6igKWzjR2YsGa2m53nKPrfK7uXYW78QLE+ATehAVZPC40szvAiA6NEU5gCYB4c4qaQzqDh2ugcHgA=",
        "dataType": "call",
        "data": {
            "method": "addAuditor",
            "params": {
                "address": "hx2d54d5ca2a1dffbcfc3fb2c86cc07cb826f6b931"
            }
        }
    }
}
```

## removeAuditor

* Removes an address from the auditor list.
* The address removed from the auditor list cannot call `acceptScore` and `rejectScore` afterward.
* This function can be invoked only by either Governance SCORE owner or the auditor herself.

### Parameters

| Key | Value Type | Description |
|:----|:-----------|-----|
| address | [T\_ADDR\_EOA](#T_ADDR_EOA) | EOA address that is in the auditor list |

### Examples

#### Request

```json
{
    "jsonrpc": "2.0",
    "id": 1234,
    "method": "icx_sendTransaction",
    "params": {
        "version": "0x3",
        "from": "hxbe258ceb872e08851f1f59694dac2558708ece11", // owner address
        "to": "cx0000000000000000000000000000000000000001",
        "stepLimit": "0x12345",
        "timestamp": "0x563a6cf330136",
        "nonce": "0x1",
        "signature": "VAia7YZ2Ji6igKWzjR2YsGa2m53nKPrfK7uXYW78QLE+ATehAVZPC40szvAiA6NEU5gCYB4c4qaQzqDh2ugcHgA=",
        "dataType": "call",
        "data": {
            "method": "removeAuditor",
            "params": {
                "address": "hx2d54d5ca2a1dffbcfc3fb2c86cc07cb826f6b931"
            }
        }
    }
}
```

## setStepPrice

* Sets the current step price in loop.
* Only the owner of the Governance SCORE can call this function.

### Parameters

| Key | Value Type | Description |
|:----|:-----------|-----|
| stepPrice | [T\_INT](#T_INT) | step price in loop (1 ICX == 10^18 loop) |

### Examples

#### Request

```json
{
    "jsonrpc": "2.0",
    "id": 1234,
    "method": "icx_sendTransaction",
    "params": {
        "version": "0x3",
        "from": "hxbe258ceb872e08851f1f59694dac2558708ece11", // owner address
        "to": "cx0000000000000000000000000000000000000001",
        "stepLimit": "0x12345",
        "timestamp": "0x563a6cf330136",
        "nonce": "0x1",
        "signature": "VAia7YZ2Ji6igKWzjR2YsGa2m53nKPrfK7uXYW78QLE+ATehAVZPC40szvAiA6NEU5gCYB4c4qaQzqDh2ugcHgA=",
        "dataType": "call",
        "data": {
            "method": "setStepPrice",
            "params": {
                "stepPrice": "0xe8d4a51000" // 1000000000000
            }
        }
    }
}
```

## setStepCost

* Sets the step cost for a specific action of SCORE.
* Only the owner of the Governance SCORE can call this function.

### Parameters

| Key | Value Type | Description |
|:----|:-----------|-----|
| stepType | [T\_STRING](#T_STRING) | action type |
| cost | [T\_INT](#T_INT) | step cost for the type |

### Examples

#### Request

```json
{
    "jsonrpc": "2.0",
    "id": 1234,
    "method": "icx_sendTransaction",
    "params": {
        "version": "0x3",
        "from": "hxbe258ceb872e08851f1f59694dac2558708ece11", // owner address
        "to": "cx0000000000000000000000000000000000000001",
        "stepLimit": "0x12345",
        "timestamp": "0x563a6cf330136",
        "nonce": "0x1",
        "signature": "VAia7YZ2Ji6igKWzjR2YsGa2m53nKPrfK7uXYW78QLE+ATehAVZPC40szvAiA6NEU5gCYB4c4qaQzqDh2ugcHgA=",
        "dataType": "call",
        "data": {
            "method": "setStepCost",
            "params": {
                "stepType": "contractDestruct",
                "cost": "-0x1b58" // -7000
            }
        }
    }
}
```

## setMaxStepLimit

* Sets the maximum step limit value.
* Only the owner can call this function.

### Parameters

| Key | Value Type | Description |
|:----|:-----------|-----|
| contextType | [T\_STRING](#T_STRING) | 'invoke' for sendTransaction, 'query' for call |
| value | [T\_INT](#T_INT) | max value for the context |

### Examples

#### Request

```json
{
    "jsonrpc": "2.0",
    "id": 1234,
    "method": "icx_sendTransaction",
    "params": {
        "version": "0x3",
        "from": "hxbe258ceb872e08851f1f59694dac2558708ece11", // owner address
        "to": "cx0000000000000000000000000000000000000001",
        "stepLimit": "0x12345",
        "timestamp": "0x563a6cf330136",
        "nonce": "0x1",
        "signature": "VAia7YZ2Ji6igKWzjR2YsGa2m53nKPrfK7uXYW78QLE+ATehAVZPC40szvAiA6NEU5gCYB4c4qaQzqDh2ugcHgA=",
        "dataType": "call",
        "data": {
            "method": "setMaxStepLimit",
            "params": {
                "contextType": "invoke",
                "value": "0x883311220099"
            }
        }
    }
}
```

## addDeployer

* Adds a new address to the deployer list.
* Deployer has the authority to register any SCORE without going through the audit process.
* Only the owner of the Governance SCORE can call this function.

### Parameters

| Key | Value Type | Description |
|:----|:-----------|-----|
| address | [T\_ADDR\_EOA](#T_ADDR_EOA) | New EOA address that will be added to the deployer list |

### Examples

#### Request

```json
{
    "jsonrpc": "2.0",
    "id": 1234,
    "method": "icx_sendTransaction",
    "params": {
        "version": "0x3",
        "from": "hxbe258ceb872e08851f1f59694dac2558708ece11", // owner address
        "to": "cx0000000000000000000000000000000000000001",
        "stepLimit": "0x12345",
        "timestamp": "0x563a6cf330136",
        "nonce": "0x1",
        "signature": "VAia7YZ2Ji6igKWzjR2YsGa2m53nKPrfK7uXYW78QLE+ATehAVZPC40szvAiA6NEU5gCYB4c4qaQzqDh2ugcHgA=",
        "dataType": "call",
        "data": {
            "method": "addDeployer",
            "params": {
                "address": "hx2d54d5ca2a1dffbcfc3fb2c86cc07cb826f6b931"
            }
        }
    }
}
```

## removeDeployer

* Removes an address from the deployer list.
* The address removed from the deployer list cannot register SCORE afterward.
* This function can be invoked only by either Governance SCORE owner or the deployer herself.

### Parameters

| Key | Value Type | Description |
|:----|:-----------|-----|
| address | [T\_ADDR\_EOA](#T_ADDR_EOA) | EOA address that is in the deployer list |

### Examples

#### Request

```json
{
    "jsonrpc": "2.0",
    "id": 1234,
    "method": "icx_sendTransaction",
    "params": {
        "version": "0x3",
        "from": "hxbe258ceb872e08851f1f59694dac2558708ece11", // owner address
        "to": "cx0000000000000000000000000000000000000001",
        "stepLimit": "0x12345",
        "timestamp": "0x563a6cf330136",
        "nonce": "0x1",
        "signature": "VAia7YZ2Ji6igKWzjR2YsGa2m53nKPrfK7uXYW78QLE+ATehAVZPC40szvAiA6NEU5gCYB4c4qaQzqDh2ugcHgA=",
        "dataType": "call",
        "data": {
            "method": "removeDeployer",
            "params": {
                "address": "hx2d54d5ca2a1dffbcfc3fb2c86cc07cb826f6b931"
            }
        }
    }
}
```

## addToScoreBlackList

* Adds a new SCORE address to the black list that caused fatal problems.
* SCOREs in the block list will not be invoked afterward. 
* Only the owner of the Governance SCORE can call this function.

### Parameters

| Key | Value Type | Description |
|:----|:-----------|-----|
| address | [T\_ADDR\_SCORE](#T_ADDR_SCORE) | New SCORE address that will be added to the black list |

### Examples

#### Request

```json
{
    "jsonrpc": "2.0",
    "id": 1234,
    "method": "icx_sendTransaction",
    "params": {
        "version": "0x3",
        "from": "hxbe258ceb872e08851f1f59694dac2558708ece11", // owner address
        "to": "cx0000000000000000000000000000000000000001",
        "stepLimit": "0x12345",
        "timestamp": "0x563a6cf330136",
        "nonce": "0x1",
        "signature": "VAia7YZ2Ji6igKWzjR2YsGa2m53nKPrfK7uXYW78QLE+ATehAVZPC40szvAiA6NEU5gCYB4c4qaQzqDh2ugcHgA=",
        "dataType": "call",
        "data": {
            "method": "addToScoreBlackList",
            "params": {
                "address": "cx2d54d5ca2a1dffbcfc3fb2c86cc07cb826f6b931"
            }
        }
    }
}
```

## removeFromScoreBlackList

* Removes the SCORE address from the black list.
* Only the owner of the Governance SCORE can call this function.

### Parameters

| Key | Value Type | Description |
|:----|:-----------|-----|
| address | [T\_ADDR\_SCORE](#T_ADDR_SCORE) | SCORE address that is in the black list |

### Examples

#### Request

```json
{
    "jsonrpc": "2.0",
    "id": 1234,
    "method": "icx_sendTransaction",
    "params": {
        "version": "0x3",
        "from": "hxbe258ceb872e08851f1f59694dac2558708ece11", // owner address
        "to": "cx0000000000000000000000000000000000000001",
        "stepLimit": "0x12345",
        "timestamp": "0x563a6cf330136",
        "nonce": "0x1",
        "signature": "VAia7YZ2Ji6igKWzjR2YsGa2m53nKPrfK7uXYW78QLE+ATehAVZPC40szvAiA6NEU5gCYB4c4qaQzqDh2ugcHgA=",
        "dataType": "call",
        "data": {
            "method": "removeFromScoreBlackList",
            "params": {
                "address": "cx2d54d5ca2a1dffbcfc3fb2c86cc07cb826f6b931"
            }
        }
    }
}
```

## addImportWhiteList

* Adds a new import statement to the import white list
* Only the owner of the Governance SCORE can call this function.

### Parameters

| Key | Value Type | Description |
|:----|:-----------|-----|
| importStmt | [T\_IMPORT\_STMT](#T_IMPORT_STMT) | New import statement that will be added to the import white list |

### Examples

#### Request

```json
{
    "jsonrpc": "2.0",
    "id": 1234,
    "method": "icx_sendTransaction",
    "params": {
        "version": "0x3",
        "from": "hxbe258ceb872e08851f1f59694dac2558708ece11", // owner address
        "to": "cx0000000000000000000000000000000000000001",
        "stepLimit": "0x12345",
        "timestamp": "0x563a6cf330136",
        "nonce": "0x1",
        "signature": "VAia7YZ2Ji6igKWzjR2YsGa2m53nKPrfK7uXYW78QLE+ATehAVZPC40szvAiA6NEU5gCYB4c4qaQzqDh2ugcHgA=",
        "dataType": "call",
        "data": {
            "method": "addImportWhiteList",
            "params": {
                "importStmt": "{'json': [],'os': ['path'],'base.exception': ['ExceptionCode','RevertException']}"
            }
        }
    }
}
```

## removeImportWhiteList

* Removes the import statement from the import white list.
* Only the owner of the Governance SCORE can call this function.

### Parameters

| Key | Value Type | Description |
|:----|:-----------|-----|
| importStmt | [T\_IMPORT\_STMT](#T_IMPORT_STMT) | Import statement that is in the import white list |

### Examples

#### Request

```json
{
    "jsonrpc": "2.0",
    "id": 1234,
    "method": "icx_sendTransaction",
    "params": {
        "version": "0x3",
        "from": "hxbe258ceb872e08851f1f59694dac2558708ece11", // owner address
        "to": "cx0000000000000000000000000000000000000001",
        "stepLimit": "0x12345",
        "timestamp": "0x563a6cf330136",
        "nonce": "0x1",
        "signature": "VAia7YZ2Ji6igKWzjR2YsGa2m53nKPrfK7uXYW78QLE+ATehAVZPC40szvAiA6NEU5gCYB4c4qaQzqDh2ugcHgA=",
        "dataType": "call",
        "data": {
            "method": "removeImportWhiteList",
            "params": {
                "importStmt": "{'json': [],'os': ['path'],'base.exception': ['ExceptionCode','RevertException']}"
            }
        }
    }
}
```

## updateServiceConfig

* update service config.
* this value is implemented using BitFlag
* Only the owner of the Governance SCORE can call this function.

### IconServiceConfig
| Key | BitFlag Value | Description |
|----|----|----|
| fee | 1 | Enable Fee |
| audit | 2 | Enalble Audit |
| deployerWhiteList | 4 | Enable DeployWhiteList |
| scorePackageValidator | 8 | Enable SCORE Package Validator |

### Parameters

| Key | Value Type | Description |
|:----|:-----------|-----|
| serviceFlag | [T\_INT](#T_INT) | flag for update service config|

### Examples
* set value 3 if you want to activate service about Fee and Audit
* set value 8 if you want to activate service about only SCORE Package Validator

#### Request

```json
{
    "jsonrpc": "2.0",
    "id": 1234,
    "method": "icx_sendTransaction",
    "params": {
        "version": "0x3",
        "from": "hxbe258ceb872e08851f1f59694dac2558708ece11", // owner address
        "to": "cx0000000000000000000000000000000000000001",
        "stepLimit": "0x12345",
        "timestamp": "0x563a6cf330136",
        "nonce": "0x1",
        "signature": "VAia7YZ2Ji6igKWzjR2YsGa2m53nKPrfK7uXYW78QLE+ATehAVZPC40szvAiA6NEU5gCYB4c4qaQzqDh2ugcHgA=",
        "dataType": "call",
        "data": {
            "method": "updateServiceConfig",
            "params": {
                "servoceFlag": "0x1"
            }
        }
    }
}
```

## setRevision

* set revision and debug version.
* have to increasement
* Only the owner of the Governance SCORE can call this function.

### Parameters

| Key | Value Type | Description |
|:----|:-----------|-----|
| code | [T\_INT](#T_INT) | revision number |
| name | [T\_STRING](#T_STRING) | revision name |

### Examples

#### Request

```json
{
    "jsonrpc": "2.0",
    "id": 1234,
    "method": "icx_sendTransaction",
    "params": {
        "version": "0x3",
        "from": "hxbe258ceb872e08851f1f59694dac2558708ece11", // owner address
        "to": "cx0000000000000000000000000000000000000001",
        "stepLimit": "0x12345",
        "timestamp": "0x563a6cf330136",
        "nonce": "0x1",
        "signature": "VAia7YZ2Ji6igKWzjR2YsGa2m53nKPrfK7uXYW78QLE+ATehAVZPC40szvAiA6NEU5gCYB4c4qaQzqDh2ugcHgA=",
        "dataType": "call",
        "data": {
            "method": "setRevision",
            "params": {
                "code": "0x1",
                "name": "1.1.0"
            }
        }
    }
}
```


# Eventlog

## Accepted

Triggered on any successful acceptScore transaction.

```python
@eventlog(indexed=1)
def Accepted(self, txHash: str):
    pass
```

## Rejected

Triggered on any successful rejectScore transaction.

```python
@eventlog(indexed=1)
def Rejected(self, txHash: str, reason: str):
    pass
```

## StepPriceChanged

Triggered on any successful setStepPrice transaction.

```python
@eventlog(indexed=1)
def StepPriceChanged(self, stepPrice: int):
    pass
```

## StepCostChanged

Triggered on any successful setStepCost transaction.

```python
@eventlog(indexed=1)
def StepCostChanged(self, stepType: str, cost: int):
    pass
```

## MaxStepLimitChanged

Triggered on any successful setMaxStepLimit transaction.

```python
@eventlog(indexed=1)
def MaxStepLimitChanged(self, contextType: str, value: int):
    pass
```

## AddImportWhiteListLog

Trigger on addImportWhiteList transaction change import white list.

```python
@eventlog(indexed=0)
def AddImportWhiteListLog(self, add_list: str, add_count: int):
    pass
```

## RemoveImportWhiteListLog

Trigger on removeImportWhiteList transaction change import white list.

```python
@eventlog(indexed=0)
def RemoveImportWhiteListLog(self, remove_list: str, remove_count: int):
    pass
```

## UpdateServiceConfigLog

Trigger on updateServiceConfig transaction.

```python
@eventlog(indexed=0)
def UpdateServiceConfigLog(self, serviceFlag: int):
    pass
```
