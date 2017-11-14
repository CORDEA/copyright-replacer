# Copyright replacer

## Usage

```console
$ nim c copyright_replacer.nim
```

```console
$ git config --get user.name
Yoshihiro Tanaka
$ ./copyright_replacer LICENSE
$ git diff | tail -n 5
-   Copyright {yyyy} {name of copyright owner}"
+   Copyright 2017 Yoshihiro Tanaka"
 
    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
```

```console
$ head -n 5 hoge.nim
# Copyright 2015 Yoshihiro Tanaka
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
$ ./copyright_replacer hoge.nim
$ head -n 5 hoge.nim
# Copyright 2015-2017 Yoshihiro Tanaka
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
```

Or specify a directory.
