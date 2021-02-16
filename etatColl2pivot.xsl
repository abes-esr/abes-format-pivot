<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:mets="http://www.loc.gov/METS/"
    xmlns:xlink="http://www.w3.org/1999/xlink"
    xmlns:metsRights="http://cosimo.stanford.edu/sdr/metsrights/"
    xmlns:mads="http://www.loc.gov/mads/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:dcterms="http://purl.org/dc/terms/"
    xmlns:tef="http://www.abes.fr/abes/documents/tef"
    exclude-result-prefixes="xs mets xlink
    metsRights mads xsi dc dcterms tef" version="2.0">
    <xsl:output encoding="UTF-8" method="xml" indent="yes"/>
    <xsl:strip-space elements="*"/>
    <!-- 11/02/2020 MJN Complément à marc2pivot pour les états de collection à partir d'une extraction partielle depuis Périscope-->
    <!-- Pour asciiser les caracteres exotiques dans les uris -->
    <xsl:variable name="nonascii">
        <xsl:text>0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyzⒶＡÀÁÂẦẤẪẨÃĀĂẰẮẴẲȦǠÄǞẢÅǺǍȀȂẠẬẶḀĄȺⱯⒷＢḂḄḆɃｃⒸＣꜾḈÇCĆĈĊČÇƇȻⒹＤḊĎḌḐḒḎĐƊƉᴅꝹɛⒺＥÈÉÊỀẾỄỂẼĒḔḖĔĖËẺĚȄȆẸỆȨḜĘḘḚƐƎᴇꝼⒻＦḞƑꝻⒼＧǴĜḠĞĠǦĢǤƓꞠꝽꝾɢⒽＨĤḢḦȞḤḨḪĦⱧⱵꞍⒾＩÌÍÎĨĪĬİÏḮỈǏȈȊỊĮḬƗⒿＪĴɈȷⓀＫḰǨḲĶḴƘⱩꝀꝂꝄꞢⓁＬĿĹĽḶḸĻḼḺŁȽⱢⱠꝈꝆꞀⓂＭḾṀṂⱮƜϻꞤȠⓃＮǸŃÑṄŇṆŅṊṈƝꞐᴎⓄＯÒÓÔỒỐỖỔÕṌȬṎŌṐṒŎȮȰÖȪỎŐǑȌȎƠỜỚỠỞỢỌỘǪǬØǾƆƟꝊꝌⓅＰṔṖƤⱣꝐꝒꝔⓆＱꝖꝘɊⓇＲŔṘŘȐȒṚṜŖṞɌⱤꝚꞦꞂⓈＳẞŚṤŜṠŠṦṢṨȘŞⱾꞨꞄⓉＴṪŤṬȚŢṰṮŦƬƮȾꞆⓊＵÙÚÛŨṸŪṺŬÜǛǗǕǙỦŮŰǓȔȖƯỪỨỮỬỰỤṲŲṶṴɄⓋＶṼṾƲꝞɅⓌＷẀẂŴẆẄẈⱲⓍＸẊẌⓎＹỲÝŶỸȲẎŸỶỴƳɎỾⓏＺŹẐŻŽẒẔƵȤⱿⱫꝢⓐａẚàáâầấẫẩãāăằắẵẳȧǡäǟảåǻǎȁȃạậặḁąⱥɐɑⓑｂḃḅḇƀⓒćĉċčçḉƈȼꜿↄⓓｄḋďḍḑḓḏđƌɖɗƋᏧԁꞪⓔｅèéêềếễểẽēḕḗĕėëẻěȅȇẹệȩḝęḙḛɇǝⓕｆḟƒⓖｇǵĝḡğġǧģǥɠꞡꝿᵹⓗｈĥḣḧȟḥḩḫẖħⱨⱶɥⓘｉìíîĩīĭïḯỉǐȉȋịįḭɨıⓙｊĵǰɉⓚｋḱǩḳķḵƙⱪꝁꝃꝅꞣⓛｌŀĺľḷḹļḽḻſłƚɫⱡꝉꞁꝇɭⓜｍḿṁṃɱɯⓝｎǹńñṅňṇņṋṉƞɲŉꞑꞥлԉⓞｏòóôồốỗổõṍȭṏōṑṓŏȯȱöȫỏőǒȍȏơờớỡởợọộǫǭøǿꝋꝍɵɔᴑⓟｐṕṗƥᵽꝑꝓꝕρⓠｑɋꝗꝙⓡｒŕṙřȑȓṛṝŗṟɍɽꝛꞧꞃⓢｓśṥŝṡšṧṣṩșşȿꞩꞅẛʂⓣｔṫẗťṭțţṱṯŧƭʈⱦꞇⓤｕùúûũṹūṻŭüǜǘǖǚủůűǔȕȗưừứữửựụṳųṷṵʉⓥｖṽṿʋꝟʌⓦｗẁẃŵẇẅẘẉⱳⓧｘẋẍⓨｙỳýŷỹȳẏÿỷẙỵƴɏỿⓩｚźẑżžẓẕƶȥɀⱬꝣ?°!"#$%'()*+,‐-–./:;=? @[\]^_ `{|}~&lt;&gt;&amp;</xsl:text>
    </xsl:variable>

    <xsl:variable name="ascii">
        <xsl:text>0123456789abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaabbbbbbccccccccccccccdddddddddddddeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeffffffggggggggggggggghhhhhhhhhhhhhiiiiiiiiiiiiiiiiiiijjjjjkkkkkkkkkkkkklllllllllllllllllmmmmmmmmnnnnnnnnnnnnnnnnoooooooooooooooooooooooooooooooooooooooooopppppppppqqqqqrrrrrrrrrrrrrrrrssssssssssssssssttttttttttttttuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuvvvvvvvwwwwwwwwwxxxxyyyyyyyyyyyyyyzzzzzzzzzzzzzaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaabbbbbbcccccccccccddddddddddddddddeeeeeeeeeeeeeeeeeeeeeeeeeeeeeffffgggggggggggggghhhhhhhhhhhhhhiiiiiiiiiiiiiiiiiiijjjjjkkkkkkkkkkkkklllllllllllllllllllmmmmmmmnnnnnnnnnnnnnnnnnnoooooooooooooooooooooooooooooooooooooooooooppppppppppqqqqqrrrrrrrrrrrrrrrrssssssssssssssssstttttttttttttttuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuvvvvvvvwwwwwwwwwwxxxxyyyyyyyyyyyyyyyzzzzzzzzzzzzz</xsl:text>
    </xsl:variable>
    <xsl:template match="/">
        <CollWemi>
            <xsl:apply-templates select="//ligne"/> 
        </CollWemi>
    </xsl:template>
    <xsl:template match="ligne">
        <xsl:variable name="epn" select="EPN"/>
        <xsl:variable name="idItem" select="concat('http://www.abes.fr/', PPN,'/i/',EPN)"/>
        <xsl:variable name="numSeq">
            <xsl:value-of select="count(preceding-sibling::ligne[EPN=$epn and $epn!=''])+1"/>
        </xsl:variable>
        <xsl:variable name="nbSeq">
            <xsl:value-of select="count(preceding-sibling::ligne[EPN=$epn and $epn!=''])+count(following-sibling::ligne[EPN=$epn])+1"/>
        </xsl:variable>
        <xsl:if test="$epn != ''">
        <Wemi>
            <xsl:comment>numSeq = <xsl:value-of select="$numSeq"/> ; nbSeq = <xsl:value-of select="$nbSeq"/></xsl:comment>
                <Entite id="{$idItem}">
                    <!--            <xsl:call-template name="meta">
                <xsl:with-param name="idSource" select="$idItem"/>
            </xsl:call-template>-->
                    <xsl:choose>
                        <xsl:when test="$nbSeq>1">
                            <xsl:variable name="idSeq" select="concat($idItem,'/seq',$numSeq)"/>
                            <relation xref="{$idSeq}">
                                <type>AGREGE</type>
                                <xsl:call-template name="meta">
                                    <xsl:with-param name="idSource" select="PPN"/>
                                </xsl:call-template>
                            </relation>
                        </xsl:when>
                        <xsl:when test="$nbSeq=1">
                            <xsl:call-template name="proprietes"/>
                        </xsl:when>
                    </xsl:choose>
                    <xsl:call-template name="meta">
                        <xsl:with-param name="idSource" select="PPN"/>
                    </xsl:call-template>
                </Entite>   
            <!-- Entité séquence -->
        <xsl:if test="$nbSeq>1">
           <Entite id="{concat($idItem,'/seq',$numSeq)}">
               <type lrm="ITEM_AGREGATIF">ITEM_AGREGATIF</type>
               <type>SEQUENCE</type>
              <xsl:call-template name="proprietes"/>
              <propriete nom="NUM_SEQUENCE">
                 <xsl:value-of select="$numSeq"/>
              </propriete>
               <xsl:call-template name="meta">
                   <xsl:with-param name="idSource" select="PPN"/>
               </xsl:call-template>
           </Entite>
        </xsl:if>
            </Wemi>
        </xsl:if>
    </xsl:template>
    <xsl:template name="proprietes">
        <xsl:for-each select="debut[text() != '']">
            <propriete nom="ANNEE_DEBUT">
                <xsl:value-of select="normalize-space(.)"/>
            </propriete>
        </xsl:for-each>
        <xsl:for-each select="fin[text() != '']">
            <propriete nom="ANNEE_FIN">
                <xsl:value-of select="normalize-space(.)"/>
            </propriete>
        </xsl:for-each>
        <xsl:for-each select="etat[text() != '']">
            <xsl:choose>
                <xsl:when test=".='C'">
                    <propriete nom="LACUNES">NON</propriete>
                </xsl:when>
                <xsl:when test=".='L'">
                    <propriete nom="LACUNES">OUI</propriete>
                </xsl:when>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>
    <xsl:template name="meta">
        <xsl:param name="idSource"/>
        <xsl:param name="citeDans"/>
        <propriete nom="META_SOURCE">PERISCOPE</propriete>
        <propriete nom="META_ACTEUR">XSL Pivot</propriete>
        <xsl:if test="$idSource != ''">
            <propriete nom="ID_SOURCE">
                <xsl:value-of select="$idSource"/>
            </propriete>
        </xsl:if>
        <!--<xsl:if test="$citeDans != ''">
            <propriete nom="CITE_DANS">
                <xsl:value-of select="$citeDans"/>
            </propriete>-->
        <!--</xsl:if>-->
    </xsl:template>
</xsl:stylesheet>
