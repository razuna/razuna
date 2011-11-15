This is the dynamic SQL for similar images. I can't really do it at the moment thus we are doing static

===================================
Package specifications
===================================
CREATE OR REPLACE PACKAGE similar
AS
TYPE TableRows IS REF CURSOR;

PROCEDURE img_colour
(
theprefix IN varchar2,
theimgid IN number,
rc OUT TableRows
);
    
END similar ;
/

===================================
Package body
===================================
CREATE OR REPLACE PACKAGE BODY similar AS

procedure img_colour (
theprefix IN varchar2,
theimgid IN number,
rc OUT TableRows )
IS
compare_sig ORDSYS.ORDImageSignature;
begin

-- select signature of image you want to match against
execute immediate
'SELECT t.imagesignature FROM ' || theprefix || 'images t WHERE t.img_id =' || theimgid INTO compare_sig;

'SELECT i.img_id, i.img_custom_id, i.img_publisher, i.img_license, it.img_description, count(*) over() howmany FROM ' || theprefix || 'images i LEFT JOIN ' || theprefix || 'images_text it ON it.img_id_r = i.img_id WHERE ORDSYS.IMGSimilar(i.imagesignature, :thesig ,''color=0.4 texture=0.1 shape=0.5 location=0'', 25)=1 GROUP BY i.img_id, i.img_custom_id, i.img_publisher, i.img_license, it.img_description' using compare_sig;


END img_colour;

END similar;
/
