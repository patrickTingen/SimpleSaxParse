/* 
 * Prog: SimpleCallBack.p 
 * Desc: Program to put contents from xml in a flat tt - sax handler
 * Auth: Patrick Tingen (PT)
 * 
 * ---------- --- -------------------------------------------------------------------
 * 2004-03-01 PT  Created
 * 2007-04-16 PT  Added parent# and child# to tt. 
 */
define variable gcPath       as character  no-undo initial ''.
define variable giElementId  as integer    no-undo initial 0.

define temp-table ttElement no-undo
  field iId       as integer   format '>>>9':u
  field iParentNr as integer   format '>>>9':u   
  field iChildNr  as integer   format '>>>9':u   
  field cName     as character format 'x(50)':u
  field cAttr     as character format 'x(8)':u
  field cValue    as character format 'x(30)':u
  field lOpen     as logical initial true
  index idxPrim as primary iId
  index idxOpen lOpen iId
  .                 

procedure emptyTable:
  /* Clear the table */
  define buffer bElement for ttElement. 

  empty temp-table bElement.
end procedure. /* getTable */


procedure getTable:
  /* Export the table */
  define buffer bElement for ttElement. 
  define output parameter table for bElement.
end procedure. /* getTable */


procedure startDocument:
  /* process new document */
  define buffer bElement for ttElement.

  create bElement.
  assign
    giElementId     = giElementId + 1
    bElement.iId    = giElementId
    bElement.cName  = '/':u
    bElement.lOpen  = true
    .
end procedure. /* startDocument */


procedure startElement:
  /* process new node */

  define input  parameter picNameSpaceURI as character  no-undo.
  define input  parameter picLocalName    as character  no-undo.
  define input  parameter picElement      as character  no-undo.
  define input  parameter pihAttributes   as handle     no-undo.

  define variable iAttrNr  as integer no-undo.
  define variable iChild   as integer no-undo.
  define variable iParent  as integer no-undo.
  define variable cParent  as character  no-undo.

  define buffer bElement for ttElement.

  /* add node to path */
  assign gcPath = gcPath + "/":U + picElement.

  /* Find out the child sequence number of this element within the scope of the parent */
  cParent = gcPath.
  entry(num-entries(cParent,'/':u),cParent,'/':u) = '':u.
  assign cParent = right-trim(cParent,"/":U).


  findParent:
  for each bElement
       by bElement.iId descending:

    /* When the parent is found, store its number & exit */
    if bElement.cName = cParent then
    do:
      iParent = bElement.iId.
      leave findParent.
    end.

    /* Count children */
    if bElement.cName = gcPath then iChild = iChild + 1.
  end. /* findParent */


  /* Parent might be the root */
  if iParent = 0 then iParent = 1.

  /* create a record for the node in the tt */
  create bElement.
  assign
    giElementId         = giElementId + 1
    bElement.iId       = giElementId
    bElement.iParentNr = iParent
    bElement.iChildNr  = iChild + 1
    bElement.cName     = gcPath
    bElement.lOpen     = true
    .

  do iAttrNr = 1 to pihAttributes:num-items:
    /* create a record for each attribute in the tt */
    create bElement.
    assign
      bElement.iId       = giElementId
      bElement.iParentNr = iParent
      bElement.iChildNr  = iChild + 1
      bElement.cName     = gcPath
      bElement.cAttr     = pihAttributes:get-localname-by-index(iAttrNr)
      bElement.cValue    = pihAttributes:get-value-by-index(iAttrNr)
      bElement.lOpen     = false
      .
  end. /* pihAttributes */
end procedure. /* startElement */


procedure characters:
  /* process node text */

  define input  parameter charData as memptr     no-undo.
  define input  parameter numChars as integer    no-undo.

  define variable cData as character  no-undo.
  define buffer bElement for ttElement.

  find last bElement where lOpen = true use-index idxOpen. 

  assign
    cData            = get-string(charData, 1, get-size(charData))
    cData            = replace(cData,chr(10),'':u)
    cData            = replace(cData,chr(13),'':u)
    bElement.cValue = bElement.cValue + trim(cData) 
    .

end procedure. /* characters */


procedure endElement:
  /* finish node */

  define input  parameter picNameSpaceURI as character  no-undo.
  define input  parameter picLocalName    as character  no-undo.
  define input  parameter picElement      as character  no-undo.

  define buffer bElement for ttElement. 

  /* find node in tt */
  find last bElement where lOpen = true use-index idxOpen.
  assign bElement.lOpen = false.

  /* adjust path for next node */
  entry(num-entries(gcPath,'/':u),gcPath,'/':u) = '':u.
  assign gcPath = right-trim(gcPath,"/":U).

end procedure. /* endElement */



procedure EndDocument.
  /* that's all folks */
  define buffer bElement for ttElement. 

  /* find node in tt */
  find last bElement where lOpen = true use-index idxOpen.
  assign bElement.lOpen = false.
end procedure. /* EndDocument */


procedure Error:
  define input parameter pcMessage as character no-undo.

  message "Schema validation error in " gcPath ": " pcMessage view-as alert-box.
  return error.
end procedure. /* Error */


procedure FatalError:
  define input parameter pcMessage as character no-undo.

  message "Fatal Error in " gcPath ": " pcMessage view-as alert-box.
  return error.
end procedure. /* FatalError */

