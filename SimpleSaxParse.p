/* 
 * Prog: SimpleSaxParse.p 
 * Desc: Program to put contents from xml in a flat tt
 * Auth: Patrick Tingen (PT)
 * 
 * ---------- --- -------------------------------------------------------------------
 * 2004-03-01 PT  Created
 * 2007-04-16 PT  Added parent# and child# to tt. 
 */
define input parameter pcXmlFile as character  no-undo.

define variable hParser          as handle     no-undo.
define variable hHandler         as handle     no-undo.
define variable iRecord          as integer    no-undo.
define variable cStartingElement as character  no-undo.
define variable cStartFolder     as character  no-undo. 

define temp-table ttElement no-undo
  field iId       as integer   format '>>>9'   label 'Seq#'
  field iParentNr as integer   format '>>>9'   label 'Parent#'
  field iChildNr  as integer   format '>>>9'   label 'Child#'
  field cName     as character format 'x(150)' label 'Element'
  field cAttr     as character format 'x(8)'   label 'Attribute'
  field cValue    as character format 'x(20)'  label 'Value'
  field lOpen     as logical initial true
  index idxPrim as primary iId
  index idxOpen lOpen iId
  .     

/* Where are we running from? */
file-info:file-name = this-procedure:file-name.
cStartFolder = replace(file-info:full-pathname,"\","/").
cStartFolder = substring(cStartFolder,1,r-index(cStartFolder,'/')).

/* Run the handler procedure */
run value(cStartFolder + 'SimpleCallBack.p') persistent set hHandler. 

/* initialize the sax reader */
create sax-reader hParser.
hParser:handler = hHandler. 

/* set document to parse */
hParser:set-input-source('file', cStartFolder + pcXmlFile).
hParser:sax-parse() no-error.

/* errors? */
if error-status:error then
do:
  if error-status:num-messages > 0 then
    message error-status:get-message(1) view-as alert-box info buttons ok.
  else 
    message return-value view-as alert-box info buttons ok.
end.

run getTable in hHandler ( output table ttElement ).

output to value(cStartFolder + 'sax-output.txt'). 
for each ttElement:
  display
    ttElement.iId
    ttElement.iParentNr
    ttElement.iChildNr
    ttElement.cName 
    ttElement.cAttr 
    ttElement.cValue 
    with width 400 stream-io.
end.
output close. 

os-command no-wait start value(cStartFolder + 'sax-output.txt'). 

finally:
  /* clean up */
  delete object hHandler.
  delete object hParser.
end finally.


