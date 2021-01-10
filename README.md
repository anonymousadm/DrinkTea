DrinkTea was developed by Python+Flask+twurl+shellscript.

This tool is used to clean your twitter account when you want to delete all tweets and remove all followers and followings.

<img src="/screenshot/DrinkTea_01.jpg">

<img src="/screenshot/DrinkTea_02.jpg">

<img src="/screenshot/DrinkTea_03.jpg">

<img src="/screenshot/DrinkTea_04.jpg">

<img src="/screenshot/DrinkTea_05.jpg">

<img src="/screenshot/DrinkTea_06.jpg">

DEMO can be access here: http://54.189.14.27:8443/, please be careful don't delete all your information by accident.

Don't forget install "jq", "json-query" and "qrencode", I already uploaded the json_query-0.0.2-py2-none-any.whl

After install the json-query need to use vi to edit /usr/local/bin/json-query like following:

```
#!/usr/bin/python
# -*- coding: utf-8 -*-
import re
import sys

from jsonquery.jsonquery import main

if __name__ == '__main__':
    sys.argv[0] = re.sub(r'(-script\.pyw?|\.exe)?$', '', sys.argv[0])
    sys.exit(main())
```
