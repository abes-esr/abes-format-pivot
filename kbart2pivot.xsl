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
    <!-- 26-02-2020 MJN : déplacement les propriétés date de début, fin, num et vol début et fin pour les revues, depuis le niveau manif électronique vers l'item (équivalent d'un état de collection)
                          Ajout du type OeuvreAgrégative et ManifestationAgregative pour les revues-->
    <!-- Pour asciiser les caracteres exotiques dans les uris -->
    <xsl:variable name="nonascii">
        <xsl:text>0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyzⒶＡÀÁÂẦẤẪẨÃĀĂẰẮẴẲȦǠÄǞẢÅǺǍȀȂẠẬẶḀĄȺⱯⒷＢḂḄḆɃｃⒸＣꜾḈÇCĆĈĊČÇƇȻⒹＤḊĎḌḐḒḎĐƊƉᴅꝹɛⒺＥÈÉÊỀẾỄỂẼĒḔḖĔĖËẺĚȄȆẸỆȨḜĘḘḚƐƎᴇꝼⒻＦḞƑꝻⒼＧǴĜḠĞĠǦĢǤƓꞠꝽꝾɢⒽＨĤḢḦȞḤḨḪĦⱧⱵꞍⒾＩÌÍÎĨĪĬİÏḮỈǏȈȊỊĮḬƗⒿＪĴɈȷⓀＫḰǨḲĶḴƘⱩꝀꝂꝄꞢⓁＬĿĹĽḶḸĻḼḺŁȽⱢⱠꝈꝆꞀⓂＭḾṀṂⱮƜϻꞤȠⓃＮǸŃÑṄŇṆŅṊṈƝꞐᴎⓄＯÒÓÔỒỐỖỔÕṌȬṎŌṐṒŎȮȰÖȪỎŐǑȌȎƠỜỚỠỞỢỌỘǪǬØǾƆƟꝊꝌⓅＰṔṖƤⱣꝐꝒꝔⓆＱꝖꝘɊⓇＲŔṘŘȐȒṚṜŖṞɌⱤꝚꞦꞂⓈＳẞŚṤŜṠŠṦṢṨȘŞⱾꞨꞄⓉＴṪŤṬȚŢṰṮŦƬƮȾꞆⓊＵÙÚÛŨṸŪṺŬÜǛǗǕǙỦŮŰǓȔȖƯỪỨỮỬỰỤṲŲṶṴɄⓋＶṼṾƲꝞɅⓌＷẀẂŴẆẄẈⱲⓍＸẊẌⓎＹỲÝŶỸȲẎŸỶỴƳɎỾⓏＺŹẐŻŽẒẔƵȤⱿⱫꝢⓐａẚàáâầấẫẩãāăằắẵẳȧǡäǟảåǻǎȁȃạậặḁąⱥɐɑⓑｂḃḅḇƀⓒćĉċčçḉƈȼꜿↄⓓｄḋďḍḑḓḏđƌɖɗƋᏧԁꞪⓔｅèéêềếễểẽēḕḗĕėëẻěȅȇẹệȩḝęḙḛɇǝⓕｆḟƒⓖｇǵĝḡğġǧģǥɠꞡꝿᵹⓗｈĥḣḧȟḥḩḫẖħⱨⱶɥⓘｉìíîĩīĭïḯỉǐȉȋịįḭɨıⓙｊĵǰɉⓚｋḱǩḳķḵƙⱪꝁꝃꝅꞣⓛｌŀĺľḷḹļḽḻſłƚɫⱡꝉꞁꝇɭⓜｍḿṁṃɱɯⓝｎǹńñṅňṇņṋṉƞɲŉꞑꞥлԉⓞｏòóôồốỗổõṍȭṏōṑṓŏȯȱöȫỏőǒȍȏơờớỡởợọộǫǭøǿꝋꝍɵɔᴑⓟｐṕṗƥᵽꝑꝓꝕρⓠｑɋꝗꝙⓡｒŕṙřȑȓṛṝŗṟɍɽꝛꞧꞃⓢｓśṥŝṡšṧṣṩșşȿꞩꞅẛʂⓣｔṫẗťṭțţṱṯŧƭʈⱦꞇⓤｕùúûũṹūṻŭüǜǘǖǚủůűǔȕȗưừứữửựụṳųṷṵʉⓥｖṽṿʋꝟʌⓦｗẁẃŵẇẅẘẉⱳⓧｘẋẍⓨｙỳýŷỹȳẏÿỷẙỵƴɏỿⓩｚźẑżžẓẕƶȥɀⱬꝣ?°!"#$%'()*+,‐-–./:;=? @[\]^_ `{|}~&lt;&gt;&amp;</xsl:text>
    </xsl:variable>

    <xsl:variable name="ascii">
        <xsl:text>0123456789abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaabbbbbbccccccccccccccdddddddddddddeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeffffffggggggggggggggghhhhhhhhhhhhhiiiiiiiiiiiiiiiiiiijjjjjkkkkkkkkkkkkklllllllllllllllllmmmmmmmmnnnnnnnnnnnnnnnnoooooooooooooooooooooooooooooooooooooooooopppppppppqqqqqrrrrrrrrrrrrrrrrssssssssssssssssttttttttttttttuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuvvvvvvvwwwwwwwwwxxxxyyyyyyyyyyyyyyzzzzzzzzzzzzzaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaabbbbbbcccccccccccddddddddddddddddeeeeeeeeeeeeeeeeeeeeeeeeeeeeeffffgggggggggggggghhhhhhhhhhhhhhiiiiiiiiiiiiiiiiiiijjjjjkkkkkkkkkkkkklllllllllllllllllllmmmmmmmnnnnnnnnnnnnnnnnnnoooooooooooooooooooooooooooooooooooooooooooppppppppppqqqqqrrrrrrrrrrrrrrrrssssssssssssssssstttttttttttttttuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuvvvvvvvwwwwwwwwwwxxxxyyyyyyyyyyyyyyyzzzzzzzzzzzzz</xsl:text>
    </xsl:variable>
  <!--  <xsl:variable name="idBouquet" select="lower-case(normalize-space(/kbart/@id))"/>
    <xsl:variable name="racineId" select="concat('http://www.abes.fr/kbart/', $idBouquet)"/>
   --> 
    <xsl:template match="/">
        <CollWemi>
            <xsl:apply-templates select="//kbart"> </xsl:apply-templates>
        </CollWemi>
    </xsl:template><xsl:template match="kbart">
        <xsl:variable name="idBouquet" select="lower-case(normalize-space(@id))"/>
        <xsl:variable name="racineId" select="concat('http://www.abes.fr/kbart/', $idBouquet)"/>
        
        <Wemi>
            <xsl:attribute name="id" select="concat($racineId, '/wemi')"/>
            <Entite id="{$racineId}">
                <type lrm="ENSEMBLE">ENSEMBLE</type>
                <type>BOUQUET</type>
                <xsl:call-template name="meta">
                    <xsl:with-param name="idSource" select="$idBouquet"/>
                </xsl:call-template>
            </Entite>
            <xsl:apply-templates select="ligne">
                <xsl:with-param name="racineId" select="$racineId"/>
                <xsl:with-param name="idBouquet" select="$idBouquet"/>
            </xsl:apply-templates>
        </Wemi>
    </xsl:template>
    <xsl:template match="ligne">
        <xsl:param name="racineId"></xsl:param>
        <xsl:param name="idBouquet"></xsl:param>
        <xsl:variable name="racineIdLigne">
            <xsl:value-of select="$racineId"/>
            <xsl:choose>
                <xsl:when test="normalize-space(online_identifier) != ''">
                    <xsl:value-of select="concat('/', normalize-space(online_identifier))"/>
                </xsl:when>
                <xsl:when test="normalize-space(print_identifier) != ''">
                    <xsl:value-of select="concat('/', normalize-space(print_identifier))"/>
                </xsl:when>
               <!-- title_id pas fiable pour le nommage, il y a des doublons
                   <xsl:when test="normalize-space(title_id) != ''">
                    <xsl:value-of
                        select="concat('/', translate(normalize-space(title_id), $nonascii, $ascii))"
                    />
                </xsl:when>-->
                <xsl:otherwise> <!-- Si pas d'isbn ou issn, on concatène les 50 premières lettres du titre. Attention, doublons théoriquement possibles -->
                    <xsl:value-of
                        select="concat('/', substring(translate(normalize-space(publication_title), $nonascii, $ascii), 1, 50))"
                    />
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:variable name="typeDoc">
            <xsl:choose>
                <xsl:when test="lower-case(normalize-space(publication_type)) = 'monograph'">
                    <xsl:text>MONOGRAPHIE</xsl:text>
                </xsl:when>
                <xsl:when test="lower-case(normalize-space(publication_type)) = 'serial'">
                    <xsl:text>PUBSERIE</xsl:text>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        <Entite id="{concat($racineIdLigne, '/w')}">
            <xsl:choose>
                <xsl:when test="$typeDoc='MONOGRAPHIE'">
                    <type lrm="OEUVRE">OEUVRE</type>
                </xsl:when>
                <xsl:when test="$typeDoc='PUBSERIE'">
                    <type lrm="OEUVRE_AGREGATIVE">OEUVRE_AGREGATIVE</type>
                </xsl:when>
            </xsl:choose>
            <type>
                <xsl:value-of select="$typeDoc"/>
            </type>
            <xsl:call-template name="meta">
                <xsl:with-param name="idSource" select="$idBouquet"/>
            </xsl:call-template>
            <xsl:for-each select="notes[text() != '']">
                <propriete nom="NOTES">
                    <xsl:value-of select="normalize-space(.)"/>
                </propriete>
            </xsl:for-each>

            <!-- publication_title est obligatoire et non répétable-->
            <relation xref="{concat($racineIdLigne, '/w/nomen/1')}">
                <type>A_POUR_NOMEN</type>
                <xsl:call-template name="meta"/>
                
            </relation>
            <!-- Manifestation électronique : toujours une, par définition : seulement si isbn imprimé -->
            <relation xref="{concat($racineIdLigne, '/m/elec')}">
                <type>A_POUR_MANIFESTATION_SS_E</type>
                <xsl:call-template name="meta"/>
            </relation>
            <!-- Manifestation papier : seulement si isbn imprimé -->
            <xsl:for-each select="print_identifier[text() != '']">
                <relation xref="{concat($racineIdLigne, '/m/impr')}">
                    <type>A_POUR_MANIFESTATION_SS_E</type>
                    <xsl:call-template name="meta"/>
                </relation>
            </xsl:for-each>        </Entite>
        <!-- Nomen Titre-->
        <!-- nb: dc:title est obligatoire et non répétable-->
        <xsl:for-each select="publication_title">
            <Entite id="{concat($racineIdLigne, '/w/nomen/1')}">
        
                <xsl:call-template name="nomen">
                    <xsl:with-param name="type" select="'TITRE'"/>
                    <xsl:with-param name="typeAcces" select="'paa'"/>
                </xsl:call-template>
                <!--<propriete nom="LANGUE">
                    <xsl:call-template name="langue">
                        <xsl:with-param name="langue" select="@xml:lang"/>
                    </xsl:call-template>
                </propriete>-->
            </Entite>
        </xsl:for-each>
        <!--Manifestations-->
        <!-- Manifestation électronique : il y en a toujours une, par définition-->
        <xsl:variable name="manif" select="concat($racineIdLigne, '/m/elec')"/>
        <Entite id="{$manif}">
            <xsl:choose>
                <xsl:when test="$typeDoc='MONOGRAPHIE'">
                    <type lrm="MANIFESTATION">MANIFESTATION</type>
                </xsl:when>
                <xsl:when test="$typeDoc='PUBSERIE'">
                    <type lrm="MANIFESTATION_AGREGATIVE">MANIFESTATION_AGREGATIVE</type>
                </xsl:when>
            </xsl:choose>
            <type>
                <xsl:value-of select="$typeDoc"/>
            </type>
            <type>ELECTRONIQUE</type>
            <xsl:call-template name="meta">
                <xsl:with-param name="idSource" select="$idBouquet"/>
            </xsl:call-template>
            <!-- online_identifer -->
            <xsl:for-each select="online_identifier[text() != '']">
                <xsl:call-template name="identifiers">
                    <xsl:with-param name="typeDoc" select="$typeDoc"/>
                    <xsl:with-param name="identifier" select="name(.)"/>
                </xsl:call-template>
            </xsl:for-each>
            <!-- monographie : date publi élec-->
            <xsl:for-each select="date_monograph_published_online[text() != '']">
                <propriete nom="ANNEE_PUBLICATION">
                    <xsl:value-of select="normalize-space(.)"/>
                </propriete>
            </xsl:for-each>
            <!-- monographie : édition -->
            <xsl:for-each select="monograph_edition[text() != '']">
                <propriete nom="MENTION_EDITION">
                    <xsl:value-of select="normalize-space(.)"/>
                </propriete>
            </xsl:for-each>
            <!-- Publication mère (collection)-->
            <xsl:for-each select="parent_publication_title_id[text() != '']">
                <propriete nom="COLLECTION_ID">
                    <xsl:value-of select="normalize-space(.)"/>
                </propriete>
            </xsl:for-each>
            <!-- monographie : numéro de volume dans la collection-->
            <xsl:for-each select="monograph_volume[text() != '']">
                <propriete nom="NUM_VOL">
                    <xsl:value-of select="normalize-space(.)"/>
                </propriete>
            </xsl:for-each>
            <!-- Revues : suite de (titleid du titre précédent)-->
            <xsl:for-each select="preceding_publication_title_id[text() != '']">
                <propriete nom="SUITE_DE">
                    <xsl:value-of select="normalize-space(.)"/>
                </propriete>
            </xsl:for-each>
            <!-- Mentions de contributeurs / éditeur commercial -->
            <!-- Appel template "mention" mode création de la relation liée (1er passage)-->
            <xsl:apply-templates
                select="first_author[text() != ''] | first_editor[text() != ''] | publisher_name[text() != '']">
                <xsl:with-param name="mode" select="'relation'"/>
                <xsl:with-param name="manif" select="$manif"/>
                <xsl:with-param name="idBouquet" select="$idBouquet"/>
            </xsl:apply-templates>
            <!-- Relation item -->
            <relation xref="{$manif}/item">
                <type>A_POUR_ITEM</type>
                <xsl:call-template name="meta"/>
            </relation>
        </Entite>
        <xsl:for-each select="print_identifier[text() != '']">
            <xsl:variable name="manif" select="concat($racineIdLigne, '/m/impr')"/>
            <Entite id="{$manif}">
                <xsl:choose>
                    <xsl:when test="$typeDoc='MONOGRAPHIE'">
                        <type lrm="MANIFESTATION">MANIFESTATION</type>
                    </xsl:when>
                    <xsl:when test="$typeDoc='PUBSERIE'">
                        <type lrm="MANIFESTATION_AGREGATIVE">MANIFESTATION_AGREGATIVE</type>
                    </xsl:when>
                </xsl:choose>
                <type>
                    <xsl:value-of select="$typeDoc"/>
                </type>
                <type>IMPRIME</type>
                <xsl:call-template name="meta">
                    <xsl:with-param name="idSource" select="$idBouquet"/>
                </xsl:call-template>
                <!-- print_identifier -->
                <xsl:call-template name="identifiers">
                    <xsl:with-param name="typeDoc" select="$typeDoc"/>
                    <xsl:with-param name="identifier" select="name(.)"/>
                </xsl:call-template>
                <!-- monographie : date publi imprimé -->
                <xsl:for-each select="date_monograph_published_print[text() != '']">
                    <propriete nom="ANNEE_PUBLICATION">
                        <xsl:value-of select="normalize-space(.)"/>
                    </propriete>
                </xsl:for-each>
            </Entite>
        </xsl:for-each>
        <!-- Item -->
        <Entite id="{$manif}/item">
            <xsl:choose>
                <xsl:when test="$typeDoc = 'MONOGRAPHIE'">
                    <type lrm="ITEM">ITEM</type>
                </xsl:when>
                <xsl:otherwise>
                    <type lrm="ITEM_AGREGATIF">ITEM_AGREGATIF</type>
                </xsl:otherwise>
            </xsl:choose>
            <type>ELECTRONIQUE</type>
            <xsl:call-template name="meta">
                <xsl:with-param name="idSource" select="$idBouquet"/>
            </xsl:call-template>
            <!-- revue : date publi élec début-->
            <xsl:for-each select="date_first_issue_online[text() != '']">
                <propriete nom="ANNEE_DEBUT">
                    <xsl:value-of select="normalize-space(.)"/>
                </propriete>
            </xsl:for-each>
            <!-- revue : date publi élec fin-->
            <xsl:for-each select="date_last_issue_online[text() != '']">
                <propriete nom="ANNEE_FIN">
                    <xsl:value-of select="normalize-space(.)"/>
                </propriete>
            </xsl:for-each>
            <!-- revue : premier volume -->
            <xsl:for-each select="num_first_vol_online[text() != '']">
                <propriete nom="VOL_DEBUT">
                    <xsl:value-of select="normalize-space(.)"/>
                </propriete>
            </xsl:for-each>
            <!-- revue : premier numéro (issue)-->
            <xsl:for-each select="num_first_issue_online[text() != '']">
                <propriete nom="NUM_DEBUT">
                    <xsl:value-of select="normalize-space(.)"/>
                </propriete>
            </xsl:for-each>
            <!-- revue : dernier volume -->
            <xsl:for-each select="num_last_vol_online[text() != '']">
                <propriete nom="VOL_FIN">
                    <xsl:value-of select="normalize-space(.)"/>
                </propriete>
            </xsl:for-each>
            <!-- revue : dernier numéro (issue)-->
            <xsl:for-each select="num_last_issue_online[text() != '']">
                <propriete nom="NUM_FIN">
                    <xsl:value-of select="normalize-space(.)"/>
                </propriete>
            </xsl:for-each>
            <xsl:for-each select="title_url[text() != '']">
                <propriete nom="URI">
                    <xsl:value-of select="normalize-space(.)"/>
                </propriete>
            </xsl:for-each>
            <xsl:choose>
                <xsl:when test="access_type[text() = 'P']">
                    <propriete nom="ACCESS_TYPE">Payant</propriete>
                </xsl:when>
                <xsl:when test="access_type[text() = 'F']">
                    <propriete nom="ACCESS_TYPE">Accès ouvert</propriete>
                </xsl:when>
            </xsl:choose>
            <xsl:for-each select="coverage_depth[text() != '']">
                <propriete nom="COUVERTURE">
                    <xsl:value-of select="."/>
                </propriete>
            </xsl:for-each>
            <relation xref="{$racineId}">
                <type>EST_AGREGE_DANS</type>
                <xsl:call-template name="meta"/>
            </relation>
        </Entite>
        <!-- Appel template "mention" mode création de l'entité liée (2e passage)-->
        <xsl:apply-templates
            select="first_author[text() != ''] | first_editor[text() != ''] | publisher_name[text() != '']">
            <xsl:with-param name="mode" select="'entite'"/>
            <xsl:with-param name="manif" select="$manif"/>
            <xsl:with-param name="idBouquet" select="$idBouquet"/>
        </xsl:apply-templates>
    </xsl:template>
    <!-- Template commun aux champs print_identifier et online_identifier -->
    <xsl:template name="identifiers">
        <xsl:param name="typeDoc"/>
        <xsl:param name="identifier"/>
        <xsl:choose>
            <xsl:when test="$typeDoc = 'PUBSERIE'">
                <propriete nom="ISSN">
                    <xsl:value-of select="normalize-space(.)"/>
                </propriete>
            </xsl:when>
            <xsl:when test="$typeDoc = 'MONOGRAPHIE'">
                <xsl:choose>
                    <xsl:when test="string-length(replace(., '[^0-9]', '')) = 13">
                        <propriete nom="ISBN13">
                            <xsl:value-of select="normalize-space(.)"/>
                        </propriete>
                    </xsl:when>
                    <xsl:when test="string-length(replace(., '[^0-9]', '')) = 10">
                        <propriete nom="ISBN10">
                            <xsl:value-of select="normalize-space(.)"/>
                        </propriete>
                    </xsl:when>
                </xsl:choose>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    <!-- Traitement des mentions : mode relation, mode entité-->
    <xsl:template
        match="first_author[text() != ''] | first_editor[text() != ''] | publisher_name[text() != '']">
        <xsl:param name="mode"/>
        <xsl:param name="idBouquet"/>
        <xsl:param name="manif"/>
        <xsl:variable name="position" select="position()"/>
        <xsl:variable name="contexteId">
            <xsl:value-of select="$manif"/>
            <xs:text>/contexte/</xs:text>
            <xsl:value-of select="$position"/>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="$mode = 'relation'">
                <xsl:variable name="role">
                    <xsl:choose>
                        <xsl:when test="name(.) = 'first_author'">
                            <xsl:text>auteur</xsl:text>
                        </xsl:when>
                        <xsl:when test="name(.) = 'first_editor'">
                            <xsl:text>éditeur scientifique</xsl:text>
                        </xsl:when>
                        <xsl:when test="name(.) = 'publisher_name'">
                            <xsl:text>éditeur commercial</xsl:text>
                        </xsl:when>
                    </xsl:choose>
                </xsl:variable>
                <relation>
                    <type>A_POUR_MENTION</type>
                    <xsl:call-template name="meta"/>
                    <Entite id="{$contexteId}">
                        <type lrm="CONTEXTE">CONTEXTE</type>
                        <type>CONTRIBUTION</type>
                        <xsl:call-template name="meta">
                            <xsl:with-param name="idSource" select="$idBouquet"/>
                        </xsl:call-template>
                        <propriete nom="ROLE">
                            <xsl:value-of select="$role"/>
                        </propriete>
                        <relation xref="{$contexteId}/contrib/nomen">
                            <type>A_POUR_MENTION_DE_CONTRIBUTEUR</type>
                            <xsl:call-template name="meta"/>
                        </relation>
                    </Entite>
                </relation>
            </xsl:when>
            <xsl:when test="$mode = 'entite'">
                <xsl:variable name="type">
                    <xsl:choose>
                        <xsl:when test="name(.) = 'first_author' or name(.) = 'first_editor'">
                            <xsl:text>PERSONNE</xsl:text>
                        </xsl:when>
                        <xsl:when test="name(.) = 'publisher_name'">
                            <xsl:text>COLLECTIVITE</xsl:text>
                        </xsl:when>
                    </xsl:choose>
                </xsl:variable>
                <Entite id="{$contexteId}/contrib/nomen">
                    <xsl:call-template name="nomen">
                        <xsl:with-param name="type" select="$type"/>
                        <xsl:with-param name="typeAcces" select="'ng'"/>
                        <xsl:with-param name="idBouquet" select="$idBouquet"/>
                    </xsl:call-template>
                </Entite>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    <!-- Traitement des nomens -->
    <xsl:template name="nomen">
        <xsl:param name="type"/>
        <xsl:param name="typeAcces"/>
        <xsl:param name="idBouquet"/>
        <type lrm="NOMEN">NOMEN</type>
        <type>
            <xsl:value-of select="$type"/>
        </type>
        <xsl:call-template name="meta">
            <xsl:with-param name="idSource" select="$idBouquet"/>
        </xsl:call-template>
        <propriete nom="TYPE_ACCES">
            <xsl:value-of select="$typeAcces"/>
        </propriete>
        <propriete nom="VALEUR">
            <xsl:value-of select="normalize-space(.)"/>
        </propriete>
        <xsl:if test="$type = 'PERSONNE'">
            <propriete nom="NOM">
                <xsl:value-of select="normalize-space(.)"/>
            </propriete>
        </xsl:if>
        <propriete nom="ALPHABET">latin</propriete>
    </xsl:template>
    <xsl:template name="meta">
        <xsl:param name="idSource"/>
        <xsl:param name="citeDans"/>
        <propriete nom="META_SOURCE">KBART</propriete>
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
