# IRTextAttributor

Evadne Wu at Iridia Productions, 2011

* * *

The **text attributor** is a simple class that edits a NSMutableAttributedString asynchronously.

It does not hold any internal storage, instead it uses the provided mutable attribute string for everything.  Whenever `-noteMutableAttributedStringChanged:` is called, it looks at the mutable attributed string.  Currently it does zero change tracking.

first it looks at a mutable attributed string, runs a regex over its base string, and finds interesting snippets such as an URI.

Then, for each string, it appends a proctor operation object on its range as a private attribute.