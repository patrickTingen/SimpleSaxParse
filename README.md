# SimpleSaxParse
A simple SAX parse procedure for Progress 

This routine shows how you can build a generic SAX parse procedure to get the contents of an XML file into a temp-table. 
Place all programs in one folder and run the sample with a fully specified path:

`RUN d:\data\Progress\SimpleSaxParse\SimpleSaxParse.p('test.xml').`

Sample input:
``` 
<?xml version="1.0"?>
<catalog>
   <book id="bk101">
      <author>Gambardella, Matthew</author>
      <title>XML Developer's Guide</title>
      <genre>Computer</genre>
      <price>44.95</price>
      <publish_date>2000-10-01</publish_date>
      <description>An in-depth look at creating applications 
      with XML.</description>
   </book>
</catalog>
```
Will produce this output:
```
Seq# Parent# Child# Element                       Attribute Value
---- ------- ------ ----------------------------- --------- --------------------
   1       0      0 /
   2       1      1 /catalog
   3       2      1 /catalog/book
   3       2      1 /catalog/book                 id        bk101
   4       3      1 /catalog/book/author                    Gambardella, Matthew
   5       3      1 /catalog/book/title                     XML Developer's Guid
   6       3      1 /catalog/book/genre                     Computer
   7       3      1 /catalog/book/price                     44.95
   8       3      1 /catalog/book/publish_date              2000-10-01
   9       3      1 /catalog/book/description               An in-depth look at
```
