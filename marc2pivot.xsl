<?xml version="1.0" encoding="UTF-8"?>
<!-- to do au 13/01/20
    https://docs.google.com/spreadsheets/d/1QyUJcG-QmoZrJXBqZFi8T122jgKoISrNzjBm7tyV1jM/edit#gid=317192526
Niveau ITEM
- 915 $5 $a : Numéro de gestion de l'Item dans la bibliothèque 
- 930 $5RCR:EPN $bRCR $jcode de PEB $p $ z : localisation
- 955 $a $ b $ i $ r : séquence volume (format d'export différent du format de catalogage) ETAT de COLL
- 959 : lacune  ETAT de COLL
- 856 $5 $u $z (accès item)
Niveau BIBLIO
* Priorité 1 :
- 856 $u $z (sans $5 accès niveau biblio)  pour l'electronqie+ 010 $a ISBN $b contient "rel" ou "br" pour le papier
(OK le 13/01/20)  461  EST_AGREGE_DANS 
(OK 20/01/20) 454 $t traduit sous le titre (nomen d'une expression2)
* Priorité 2  :
(OK 20/01/20) 035 $a : provenance
(OK 20/01/20) 464 $t nomen des oeuvres agrégées
* Priorité 3  :
(OK le 13/01/20) 676 $a :dewey  MAIS  indexation traitée à plat "type mot clef", il faudrait une construction "type réferentiel" pour dire schema, version, langue + rendre le n° d'ordre dans la notice
(OK le 13/01/20)  320 $a zone de notes niveau manif : zone fréquente mais ne contenant pas beaucoup de caractère / la 359 contient des sommaires = structurée + beaucoup de caractères
Priorité 4 :
- 102 $a : pays de parution (referentiel sur 2 cara)
- 110 $a types de publication données codées (environ 10 codes)

-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:marc="http://www.loc.gov/MARC21/slim"
    exclude-result-prefixes="marc" version="2.0">
    <xsl:output encoding="UTF-8" method="xml" indent="yes"/>
    <xsl:strip-space elements="*"/>
    <xsl:template match="/">
        <CollWemi>
            <xsl:apply-templates select="//marc:record"> </xsl:apply-templates>
        </CollWemi>
    </xsl:template>
    <xsl:template match="marc:record">
        <xsl:variable name="type">
            <xsl:choose>
                <xsl:when test="substring(marc:leader, 7, 1) = 'l'">ELECTRONIQUE</xsl:when>
                <xsl:when test="substring(marc:leader, 7, 1) = 'a'">IMPRIME</xsl:when>
                <xsl:otherwise>AUTRE_SUPPORT</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="typePub">
            <xsl:choose>
                <xsl:when test="substring(marc:leader, 8, 1) = 'm'">
                    <type>MONOGRAPHIE</type>
                </xsl:when>
                <xsl:when test="substring(marc:leader, 8, 1) = 's'">
                    <type>PUBSERIE</type>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="typePubSerie">
            <xsl:choose>
                <xsl:when
                    test="starts-with(marc:datafield[@tag = '110']/marc:subfield[@code = 'a']/text(), 'a')"
                    >PERIODIQUE</xsl:when>
                <xsl:when
                    test="starts-with(marc:datafield[@tag = '110']/marc:subfield[@code = 'a']/text(), 'b')"
                    >COLLECTION</xsl:when>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="PPN" select="marc:controlfield[@tag = 001]"/>
        <!-- racineId : si 579, toutes les entités férivées de la notices sont nommées d'après l'id de la Tr liée. Sinon, d'après l'id de la notice, comme avant -->
        <!-- Attention : vérifier qu'on ne peut pas avoir plus d'une 579 ! -->
        <xsl:variable name="TR">
            <xsl:value-of select="boolean(marc:datafield[@tag = '579'])"/>
        </xsl:variable>
        <xsl:comment>valeur TR : <xsl:value-of select="$TR"/></xsl:comment>
        <xsl:variable name="ppnTR">
            <xsl:value-of select="marc:datafield[@tag = '579']/marc:subfield[@code = '3']"/>
        </xsl:variable>
        <xsl:variable name="racineId">
            <xsl:choose>
                <xsl:when test="$TR = 'true'">
                    <xsl:value-of
                        select="concat('http://www.abes.fr/', $ppnTR, '_', $PPN)"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="concat('http://www.abes.fr/', $PPN)"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="nbManif">
            <xsl:call-template name="manifCompte">
                <xsl:with-param name="type" select="$type"/>
                <xsl:with-param name="typePub" select="$typePub"/>
                <xsl:with-param name="typePubSerie" select="$typePubSerie"/>
                <xsl:with-param name="PPN" select="$PPN"/>
                <xsl:with-param name="racineId" select="$racineId"/>
            </xsl:call-template>
        </xsl:variable>

        <Wemi>
            <xsl:attribute name="id" select="concat($racineId, '/wemi')"/>
            <xsl:for-each select="marc:datafield[@tag = '035'][marc:subfield[@code = 'a']]">
                <propriete nom="ID_EXTERNE">
                    <xsl:value-of select="marc:subfield[@code = 'a']"/>
                    <xsl:for-each select="marc:subfield[@code = '2']">
                        <xsl:text> | </xsl:text>
                        <xsl:value-of select="marc:subfield[@code = '2']"/>
                    </xsl:for-each>
                </propriete>
            </xsl:for-each>
            <propriete nom="META_NBMANIF">
                <xsl:value-of select="$nbManif"/>
            </propriete>
            <xsl:comment>--- Oeuvre ----</xsl:comment>
            <!-- Nouveau traitement des oeuvres : s'il y a une 579, on crée seulement un entité oeuvre embryon, avec seulement la relation à l'expression (qui fusionnera ensuite avec la Tr complète générée par l'xslt ad hoc. Sinon, on fait comme avant -->
            <xsl:variable name="OeuvreId">
                <xsl:choose>
                    <xsl:when test="$TR = 'true'">
                        <xsl:value-of
                            select="concat('http://www.abes.fr/', marc:datafield[@tag = '579']/marc:subfield[@code = '3'], '/w')"
                        />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="concat($racineId, '/w')"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <Entite id="{$OeuvreId}">
                <xsl:choose>
                    <xsl:when test="$typePub = 'MONOGRAPHIE'">
                        <type lrm="OEUVRE">OEUVRE</type>
                    </xsl:when>
                    <xsl:otherwise>
                        <type lrm="OEUVRE_AGREGATIVE">OEUVRE_AGREGATIVE</type>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:if test="$typePub != ''">
                    <type>
                        <xsl:value-of select="$typePub"/>
                    </type>
                </xsl:if>
                <xsl:if test="$typePubSerie != ''">
                    <type>
                        <xsl:value-of select="$typePubSerie"/>
                    </type>
                </xsl:if>
                <xsl:call-template name="meta">
                    <xsl:with-param name="idSource">
                        <xsl:choose>
                            <xsl:when test="$TR = 'true'">
                                <xsl:value-of select="$ppnTR"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="$PPN"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:with-param>
                    <xsl:with-param name="citeDans">
                        <xsl:choose>
                            <xsl:when test="$TR = 'true'">
                                <xsl:value-of select="$PPN"/>
                            </xsl:when>
                            <xsl:otherwise/>
                        </xsl:choose>
                    </xsl:with-param>
                </xsl:call-template>
                <xsl:if test="$TR = 'false'">
                    <xsl:comment>---propriétés niveau Oeuvre ----</xsl:comment>
                    <!--propriete identifiants issn : au niveau manifestation 09/2020-->
                    <!--<xsl:for-each select="marc:datafield[@tag = '011']/marc:subfield[@code = 'a']">
                        <propriete nom="ISSN">
                            <xsl:value-of select="normalize-space(.)"/>
                        </propriete>
                    </xsl:for-each>-->
                    <!-- Langue (niveau oeuvre) -->
                    <xsl:choose>
                        <xsl:when test="marc:datafield[@tag = '101' and @ind1 = '0']">
                            <xsl:for-each
                                select="marc:datafield[@tag = '101' and @ind1 = '0']/marc:subfield[@code = 'a'][text() != '']">
                                <propriete nom="LANGUE">
                                    <xsl:call-template name="codeLangue">
                                        <xsl:with-param name="code" select="normalize-space(.)"/>
                                    </xsl:call-template>
                                    <!--<xsl:value-of select="normalize-space(text())"/>-->
                                </propriete>
                            </xsl:for-each>
                        </xsl:when>
                        <xsl:when test="marc:datafield[@tag = '101' and @ind1 = '1']">
                            <xsl:for-each
                                select="marc:datafield[@tag = '101' and @ind1 = '1']/marc:subfield[@code = 'c'][text() != '']">
                                <propriete nom="LANGUE">
                                    <xsl:call-template name="codeLangue">
                                        <xsl:with-param name="code" select="normalize-space(.)"/>
                                    </xsl:call-template>
                                    <!--<xsl:value-of select="normalize-space(text())"/>-->
                                </propriete>
                            </xsl:for-each>
                        </xsl:when>
                    </xsl:choose>
                    <!-- indexation traitée à plat "type mot clef", il faudrait une construction "type réferentiel" pour dire schema, version, langue + rendre le n° d'ordre dans la notice-->
                    <xsl:for-each
                        select="marc:datafield[@tag = '676']/marc:subfield[@code = 'a'][text() != '']">
                        <propriete nom="INDICE_DEWEY">
                            <xsl:value-of select="normalize-space(text())"/>
                        </propriete>
                    </xsl:for-each>
                    <xsl:for-each
                        select="marc:datafield[@tag = '330']/marc:subfield[@code = 'a'][text() != '']">
                        <propriete nom="RESUME">
                            <xsl:value-of select="normalize-space(text())"/>
                        </propriete>
                    </xsl:for-each>
                    <xsl:comment>---relations niveau Oeuvre ----</xsl:comment>
                    <!-- Relation avec l'entité de regroupement (500 = TU)-->
                    <xsl:for-each select="marc:datafield[@tag = '500']">
                        <xsl:choose>
                            <xsl:when test="marc:subfield[@code = '3'] != ''">
                                <relation>
                                    <xsl:attribute name="xref"
                                        select="concat('http://www.idref.fr/', marc:subfield[@code = '3'])"/>
                                    <type>EST_REGROUPE_PAR</type>
                                    <xsl:call-template name="meta"/>
                                </relation>
                            </xsl:when>
                            <xsl:when test="marc:subfield[@code = 'a'] != ''">
                                <relation>
                                    <xsl:attribute name="xref"
                                        select="concat($racineId, '/w/500/nomen', position())"/>
                                    <type>A_POUR_NOMEN</type>
                                    <xsl:call-template name="meta"/>
                                </relation>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:for-each>
                    <!-- Relation avec l'entité de regroupement (type 579 = TR)-->
                    <!--<xsl:for-each select="marc:datafield[@tag = '579']">
                        <relation>
                            <xsl:attribute name="xref"
                                select="concat('http://www.idref.fr/', marc:subfield[@code = '3'])"/>
                            <type>EST_REGROUPE_PAR</type>
                            <xsl:call-template name="meta"/>
                        </relation>
                    </xsl:for-each>-->
                    <!-- Nomen titre : provisoirement o nprend le titre de la manif, le 200$a -->
                    <xsl:for-each
                        select="marc:datafield[@tag = '200'][marc:subfield[@code = 'a'] != '']">
                        <relation>
                            <xsl:attribute name="xref"
                                select="concat($racineId, '/w/nomen/', position())"/>
                            <type>A_POUR_NOMEN</type>
                            <xsl:call-template name="meta"/>
                        </relation>
                    </xsl:for-each>
                    <!--Nomen identifiant-->
                    <xsl:for-each
                        select="marc:datafield[@tag = '011']/marc:subfield[@code = 'f'][text() != '']">
                        <relation>
                            <xsl:attribute name="xref"
                                select="concat($racineId, '/w/nomen/identifiant/', position())"/>
                            <type>A_POUR_NOMEN</type>
                            <xsl:call-template name="meta"/>
                        </relation>
                    </xsl:for-each>
                    <!-- Lien à d'autre(s) arbre(s) WEMI-->
                    <!-- RELATION 430 A_POUR_SUITE-->
                    <xsl:for-each select="marc:datafield[(@tag = '430')]">
                        <xsl:choose>
                            <xsl:when test="marc:subfield[@code = '0']">
                                <relation>
                                    <xsl:attribute name="xref"
                                        select="concat('http://www.abes.fr/', marc:subfield[@code = '0'], '/w')"/>
                                    <type>A_POUR_SUITE</type>
                                    <xsl:call-template name="meta"/>
                                    <bidon> <!-- propriétés pour xsl "bidon" pour chargement dans Oracle -->
                                        <lien>430</lien>
                                        <xsl:call-template name="zones4XX">
                                            <xsl:with-param name="typePub" select="$typePub" />
                                        </xsl:call-template>
                                        <xsl:call-template name="meta">
                                            <xsl:with-param name="idSource" select="marc:subfield[@code= '0']"/>
                                            <xsl:with-param name="citeDans" select="$PPN"/>
                                        </xsl:call-template>
                                    </bidon>
                                </relation>
                            </xsl:when>
                            <xsl:when test="marc:subfield[@code = 't']">
                                <relation>
                                    <xsl:attribute name="xref" select="concat($racineId, '/w/430/',position())"/>
                                    <type>A_POUR_SUITE</type>
                                    <xsl:call-template name="meta"/>
                                    <bidon> <!-- propriétés pour xsl "bidon" pour chargement dans Oracle -->
                                        <lien>430</lien>
                                        <xsl:call-template name="zones4XX">
                                            <xsl:with-param name="typePub" select="$typePub" />
                                        </xsl:call-template>
                                        <xsl:call-template name="meta">
                                            <xsl:with-param name="citeDans" select="$PPN"/>
                                        </xsl:call-template>
                                    </bidon>
                                </relation>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:for-each>
                    <!-- RELATION 440 EST_LA_SUITE_DE-->
                    <xsl:for-each select="marc:datafield[(@tag = '440')]">
                        <xsl:choose>
                            <xsl:when test="marc:subfield[@code = '0']">
                                <relation>
                                    <xsl:attribute name="xref"
                                        select="concat('http://www.abes.fr/', marc:subfield[@code = '0'], '/w')"/>
                                    <type>EST_LA_SUITE_DE</type>
                                    <xsl:call-template name="meta"/>
                                    <bidon> <!-- propriétés pour xsl "bidon" pour chargement dans Oracle -->
                                        <lien>440</lien>
                                        <xsl:call-template name="zones4XX">
                                            <xsl:with-param name="typePub" select="$typePub" />
                                        </xsl:call-template>
                                        <xsl:call-template name="meta">
                                            <xsl:with-param name="idSource" select="marc:subfield[@code= '0']"/>
                                            <xsl:with-param name="citeDans" select="$PPN"/>
                                        </xsl:call-template>
                                    </bidon>
                                </relation>
                            </xsl:when>
                            <xsl:when test="marc:subfield[@code = 't']">
                                <relation>
                                    <xsl:attribute name="xref" select="concat($racineId, '/w/440/',position())"/>
                                    <type>EST_LA_SUITE_DE</type>
                                    <xsl:call-template name="meta"/>
                                    <bidon> <!-- propriétés pour xsl "bidon" pour chargement dans Oracle -->
                                        <lien>440</lien>
                                        <xsl:call-template name="zones4XX">
                                            <xsl:with-param name="typePub" select="$typePub" />
                                        </xsl:call-template>
                                        <xsl:call-template name="meta">
                                            <xsl:with-param name="citeDans" select="$PPN"/>
                                        </xsl:call-template>
                                    </bidon>
                                </relation>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:for-each>
                    <!-- RELATION Contributeurs (niveau oeuvre) -->
                    <xsl:variable name="roles">010 - 070 - 257 - 340 - 395 - 440 - 651</xsl:variable>
                    <xsl:for-each
                        select="marc:datafield[starts-with(@tag, '7')][marc:subfield[@code = '3']][marc:subfield[@code = '4'][contains($roles, text())]][not(marc:subfield[@code = '5'])]">
                        <xsl:comment>---relation contributeur niveau Oeuvre ---</xsl:comment>
                        <xsl:if
                            test="not(@tag = '702' and marc:subfield[@code = '4']/text() = '440')">
                            <!--<xsl:variable name="codefct"> 
                            <xsl:value-of select="marc:subfield[@code = '4'][1]"/>
                        </xsl:variable>-->
                            <!-- test suppléméntaire pour le code de fct illustrateur : si en 702, pas dans l'oeuvre. Pour généraliser il faudrait deux variables role et cherche séparément dans 700/701/710/711/720/721, et 702/712/722-->
                            <xsl:call-template name="contrib_relation">
                                <xsl:with-param name="PPN" select="$PPN"/>
                                <xsl:with-param name="mode" select="'relation_agent'"/>
                                <!--<xsl:with-param name="codefct" select="$codefct"/>-->
                            </xsl:call-template>
                        </xsl:if>
                    </xsl:for-each>
                    <!-- RELATION CONTRIB COMMENTEE PAR ERM 
                   <xsl:variable name="roles">070 - 651 - 395 - 257 - 010 - 340</xsl:variable>
                      <xsl:for-each   select="marc:datafield[starts-with(@tag, '7')][marc:subfield[@code = '3']][contains($roles, marc:subfield[@code = '4'])]">
                    <xsl:comment>-\-\-contributeur niveau Oeuvre -\-\-\-</xsl:comment>  
                    <relation>
                        <xsl:variable name="idref"
                            select="concat('http://www.idref.fr/', marc:subfield[@code = '3'])"/>
                        <xsl:attribute name="xref">
                            <xsl:value-of select="$idref"/>
                        </xsl:attribute>
                        <type>A_POUR_CONTRIBUTEUR</type>
                        <xsl:call-template name="meta"/>
                        <xsl:call-template name="role">
                            <xsl:with-param name="codefct" select="marc:subfield[@code = '4']"/>
                        </xsl:call-template>
                    </relation>
                </xsl:for-each>-->
                    <!-- Zones troubles de l'indexation -->
                    <xsl:for-each
                        select="marc:datafield[@tag = '600' or @tag = '601' or @tag = '602' or @tag = '604' or @tag = '605' or @tag = '606' or @tag = '607' or @tag = '608']">
                        <xsl:variable name="referentiel">
                            <xsl:value-of
                                select="normalize-space(lower-case(marc:subfield[@code = '2']))"/>
                        </xsl:variable>
                        <xsl:choose>
                            <!-- RELATION A_POUR_SUJET quand absence de lien (sans @code = '3'). On ne garde que la tête de vedette (pas de construction "BOITE_SUJETS") 
                        TODO ???? -->
                            <xsl:when test="not(marc:subfield[@code = '3'])">
                                <relation>
                                    <xsl:attribute name="xref">
                                        <xsl:value-of
                                            select="concat($racineId, '/w/sujet/', position())"/>
                                    </xsl:attribute>
                                    <type>A_POUR_SUJET</type>
                                    <xsl:call-template name="meta"/>
                                </relation>
                            </xsl:when>
                            <xsl:when test="marc:subfield[@code = '3']">
                                <relation>
                                    <xsl:choose>
                                        <xsl:when test="count(marc:subfield[@code = '3']) = 1">
                                            <xsl:attribute name="xref">
                                                <xsl:value-of
                                                  select="concat('http://www.idref.fr/', marc:subfield[@code = '3'])"
                                                />
                                            </xsl:attribute>
                                            <!-- RELATION A_POUR_SUJET avec lien et pas de subdivision (1 seul @code = '3')-->
                                            <type>A_POUR_SUJET</type>
                                            <xsl:call-template name="meta"/>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <!-- RELATION2 A_POUR_INDEXATION = BOITE_SUJETS avec lien et subdivision(s) (plusieurs @code = '3')-->
                                            <type>A_POUR_INDEXATION</type>
                                            <Entite
                                                id="{concat($racineId, '/w/sujet/', position())}">
                                                <type lrm="CONTEXTE">CONTEXTE</type>
                                                <type>BOITE_SUJETS</type>
                                                <xsl:for-each select="marc:subfield[@code = '2']">
                                                  <propriete nom="REFERENTIEL">
                                                  <xsl:value-of select="$referentiel"/>
                                                  </propriete>
                                                </xsl:for-each>
                                                <xsl:call-template name="meta">
                                                  <xsl:with-param name="idSource" select="$PPN"/>
                                                </xsl:call-template>
                                                <!-- A_POUR_SUJET_PRINCIPAL appel template nommé rameau pour relation au sujet principal = vedette-->
                                                <xsl:for-each
                                                  select="marc:subfield[@code = '3'][position() = 1 and text() != '']">
                                                  <xsl:call-template name="rameau">
                                                  <xsl:with-param name="ppnRameau" select="text()"/>
                                                  <xsl:with-param name="referentiel"
                                                  select="$referentiel"/>
                                                  <xsl:with-param name="mode" select="'relation'"/>
                                                  <xsl:with-param name="typeSub" select="'vedette'"
                                                  />
                                                  </xsl:call-template>
                                                </xsl:for-each>
                                                <!-- A_POUR_SPECIFICATION_SUJET/LIEU/TEMPS appel template nommé rameau pour relation au(x) subdivivsion(s) -->
                                                <xsl:for-each
                                                  select="marc:subfield[@code = '3'][position() > 1 and text() != '']">
                                                  <xsl:call-template name="rameau">
                                                  <xsl:with-param name="ppnRameau" select="text()"/>
                                                  <xsl:with-param name="referentiel"
                                                  select="$referentiel"/>
                                                  <xsl:with-param name="mode" select="'relation'"/>
                                                  <xsl:with-param name="typeSub"
                                                  select="following-sibling::node()[1]/@code"/>
                                                  </xsl:call-template>
                                                </xsl:for-each>
                                            </Entite>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </relation>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:for-each>
                </xsl:if>
                <!-- Fin propriétés et relations oeuvre quand pas de TR -->
                <xsl:comment>---- relation(s) au(x) Expression(s) ----</xsl:comment>
                <relation>
                    <xsl:attribute name="xref" select="concat($racineId, '/e')"/>
                    <type>A_POUR_EXPRESSION</type>
                    <xsl:call-template name="meta"/>
                </relation>
            </Entite>
            <!-- ENTITE Expression -->
            <xsl:comment>---- Expression(s) ----</xsl:comment>
            <Entite id="{concat($racineId, '/e')}">
                <xsl:choose>
                    <xsl:when test="$typePub = 'MONOGRAPHIE'">
                        <type lrm="EXPRESSION">EXPRESSION</type>
                    </xsl:when>
                    <xsl:otherwise>
                        <type lrm="EXPRESSION_AGREGATIVE">EXPRESSION_AGREGATIVE</type>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:if test="$typePub != ''">
                    <type>
                        <xsl:value-of select="$typePub"/>
                    </type>
                </xsl:if>
                <xsl:if test="$typePubSerie != ''">
                    <type>
                        <xsl:value-of select="$typePubSerie"/>
                    </type>
                </xsl:if>
                <xsl:call-template name="meta">
                    <xsl:with-param name="idSource" select="$PPN"/>
                </xsl:call-template>
                <xsl:for-each
                    select="marc:datafield[@tag = '101']/marc:subfield[@code = 'a' and text() != '']">
                    <xsl:variable name="langue">
                        <xsl:value-of select="normalize-space(.)"/>
                    </xsl:variable>
                    <xsl:comment>--- propriété niveau Expression ----</xsl:comment>
                    <!-- Langue -->
                    <propriete nom="LANGUE">
                        <xsl:call-template name="codeLangue">
                            <xsl:with-param name="code" select="$langue"/>
                        </xsl:call-template>
                        <!--<xsl:value-of select="$langue"/>-->
                    </propriete>
                    <xsl:for-each
                        select="ancestor::marc:record/marc:datafield[@tag = '510'][marc:subfield[@code = 'a' and text() != ''] and marc:subfield[@code = 'z'] = $langue]">
                        <xsl:comment>---relations niveau Expression ----</xsl:comment>
                        <relation>
                            <xsl:attribute name="xref"
                                select="concat($racineId, '/e/nomen/', position())"/>
                            <type>A_POUR_NOMEN</type>
                            <xsl:call-template name="meta"/>
                        </relation>

                    </xsl:for-each>
                </xsl:for-each>
                <!-- RELATION Contributeurs (niveau expression) -->
                <xsl:variable name="roles">730</xsl:variable>
                <xsl:for-each
                    select="marc:datafield[starts-with(@tag, '7')][marc:subfield[@code = '3']][marc:subfield[@code = '4'][contains($roles, text())]][not(marc:subfield[@code = '5'])]">
                    <xsl:comment>--- relation contributeur niveau Expression ---</xsl:comment>
                    <!--<xsl:variable name="codefct"> 
                        <xsl:value-of select="marc:subfield[@code = '4'][1]"/>
                    </xsl:variable>-->
                    <xsl:call-template name="contrib_relation">
                        <xsl:with-param name="PPN" select="$PPN"/>
                        <xsl:with-param name="mode" select="'relation_agent'"/>
                        <!--<xsl:with-param name="codefct" select="$codefct"/>-->
                    </xsl:call-template>
                </xsl:for-each>
                <!-- RELATION CONTRIB COMMENTEE PAR ERM 
                 <xsl:for-each
                    select="marc:datafield[starts-with(@tag, '7')][marc:subfield[@code = '3']][marc:subfield[@code = '4'] = '730']">
                    <xsl:comment>-\-\-contributeur niveau Expression -\-\-\-</xsl:comment>
                    <relation>
                        <xsl:variable name="idref"
                            select="concat('http://www.idref.fr/', marc:subfield[@code = '3'])"/>
                        <xsl:attribute name="xref">
                            <xsl:value-of select="$idref"/>
                        </xsl:attribute>
                        <type>A_POUR_CONTRIBUTEUR</type>
                        <xsl:call-template name="meta"/>
                        <xsl:call-template name="role">
                            <xsl:with-param name="codefct" select="marc:subfield[@code = '4']"/>
                        </xsl:call-template>
                    </relation>
                </xsl:for-each>-->
                <!-- RELATION 454 EST_TRADUIT_DE-->
                <xsl:for-each select="marc:datafield[(@tag = '454')]">
                    <xsl:choose>
                        <xsl:when test="marc:subfield[@code = '0']">
                            <relation>
                                <xsl:attribute name="xref"
                                    select="concat('http://www.abes.fr/', marc:subfield[@code = '0'], '/e')"/>
                                <type>EST_TRADUIT_DE</type>
                                <xsl:call-template name="meta"/>
                                <bidon> <!-- propriétés pour xsl "bidon" pour chargement dans Oracle -->
                                    <lien>454</lien>
                                    <xsl:call-template name="zones4XX">
                                            <xsl:with-param name="typePub" select="$typePub" />
                                        </xsl:call-template>
                                    <xsl:call-template name="meta">
                                        <xsl:with-param name="idSource" select="marc:subfield[@code= '0']"/>
                                        <xsl:with-param name="citeDans" select="$PPN"/>
                                    </xsl:call-template>
                                </bidon>
                            </relation>
                        </xsl:when>
                        <xsl:when test="marc:subfield[@code = 't']">
                            <relation>
                                <xsl:attribute name="xref" select="concat($racineId, '/e/454/',position())"/>
                                <type>EST_TRADUIT_DE</type>
                                <xsl:call-template name="meta"/>
                                <bidon> <!-- propriétés pour xsl "bidon" pour chargement dans Oracle -->
                                    <lien>454</lien>
                                    <xsl:call-template name="zones4XX">
                                            <xsl:with-param name="typePub" select="$typePub" />
                                        </xsl:call-template>
                                    <xsl:call-template name="meta">
                                        <xsl:with-param name="citeDans" select="$PPN"/>
                                    </xsl:call-template>
                                </bidon>
                            </relation>
                        </xsl:when>
                    </xsl:choose>
                </xsl:for-each>
                <xsl:comment>----<xsl:value-of select="$nbManif"/> relation(s) au(x) Manifestation(s) ----</xsl:comment>
                <xsl:call-template name="manifBoucle">
                    <xsl:with-param name="type" select="$type"/>
                    <xsl:with-param name="typePub" select="$typePub"/>
                    <xsl:with-param name="typePubSerie" select="$typePubSerie"/>
                    <xsl:with-param name="PPN" select="$PPN"/>
                    <xsl:with-param name="racineId" select="$racineId"/>
                    <xsl:with-param name="mode" select="'relation'"/>
                    <xsl:with-param name="fin" select="$nbManif"/>
                    <xsl:with-param name="nbManif" select="$nbManif"/>
                    <xsl:with-param name="compteur" select="1"/>
                    <xsl:with-param name="typeManif">
                        <xsl:choose>
                            <xsl:when test="number($nbManif) = 1">
                                <xsl:text>manifExemplaires</xsl:text>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>manifSansExemplaire</xsl:text>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:with-param>
                </xsl:call-template>
            </Entite>
            <!-- ENTITE 454 EST_LA_TRADUCTION_DE-->
            <!--<xsl:for-each select="marc:datafield[(@tag = '454')]">
                <xsl:choose>
                    <!-\- 454 $0 EST_LA_TRADUCTION_DE-\->
                    <xsl:when test="marc:subfield[@code = '0']">
                        <Entite>
                            <xsl:attribute name="id"
                                select="concat('http://www.abes.fr/', marc:subfield[@code = '0'], '/e')"/>
                            <xsl:choose>
                                <xsl:when test="$typePub = 'MONOGRAPHIE'">
                                    <type lrm="EXPRESSION">EXPRESSION</type>
                                </xsl:when>
                                <xsl:otherwise>
                                    <type lrm="EXPRESSION_AGREGATIVE">EXPRESSION_AGREGATIVE</type>
                                </xsl:otherwise>
                            </xsl:choose>
                            <type>
                                <xsl:value-of select="$typePub"/>
                            </type>
                            <xsl:call-template name="meta">
                                <xsl:with-param name="idSource" select="marc:subfield[@code = '0']"/>
                                <xsl:with-param name="citeDans" select="$PPN"/>
                            </xsl:call-template>
                        </Entite>
                    </xsl:when>
                    <!-\- 454 $t EST_LA_TRADUCTION_DE-\->
                    <xsl:when test="marc:subfield[@code = 't'][text() != '']">
                        <Entite>
                            <xsl:attribute name="id" select="concat($racineId, '/e/454/',position())"/>
                            <xsl:choose>
                                <xsl:when test="$typePub = 'MONOGRAPHIE'">
                                    <type lrm="EXPRESSION">EXPRESSION</type>
                                </xsl:when>
                                <xsl:otherwise>
                                    <type lrm="EXPRESSION_AGREGATIVE">EXPRESSION_AGREGATIVE</type>
                                </xsl:otherwise>
                            </xsl:choose>
                            <type>
                                <xsl:value-of select="$typePub"/>
                            </type>
                            <xsl:call-template name="meta">
                                <xsl:with-param name="citeDans" select="$PPN"/>
                            </xsl:call-template>
                            <relation xref="{concat($racineId,'/e/454/',position(),'/nomen')}">
                                <type>A_POUR_NOMEN</type>
                                <xsl:call-template name="meta"/>
                            </relation>
                        </Entite>
                        <Entite id="{concat($racineId,'/e/454/',position(),'/nomen')}">
                            <type lrm="NOMEN">NOMEN</type>
                            <type>TITRE</type>
                            <propriete nom="TYPE_ACCES">ng</propriete>
                            <propriete nom="VALEUR">
                                <xsl:value-of select="normalize-space(marc:subfield[@code = 't'])"/>
                            </propriete>
                            <xsl:call-template name="meta">
                                <xsl:with-param name="idSource" select="$PPN"/>
                            </xsl:call-template>
                        </Entite>
                    </xsl:when>
                </xsl:choose>
            </xsl:for-each>-->
            <!-- ENTITE Manifestation -->
            <xsl:comment>----<xsl:value-of select="$nbManif"/> entite(s) Manifestation(s) ----</xsl:comment>
            <xsl:call-template name="manifBoucle">
                <xsl:with-param name="type" select="$type"/>
                <xsl:with-param name="typePub" select="$typePub"/>
                <xsl:with-param name="typePubSerie" select="$typePubSerie"/>
                <xsl:with-param name="PPN" select="$PPN"/>
                <xsl:with-param name="racineId" select="$racineId"/>
                <xsl:with-param name="mode" select="'entite'"/>
                <xsl:with-param name="fin" select="$nbManif"/>
                <xsl:with-param name="compteur" select="1"/>
                <xsl:with-param name="nbManif" select="$nbManif"/>
                <xsl:with-param name="typeManif">
                    <xsl:choose>
                        <xsl:when test="number($nbManif) = 1">
                            <xsl:text>manifExemplaires</xsl:text>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:text>manifSansExemplaire</xsl:text>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:with-param>
            </xsl:call-template>
            <!-- ENTITE Titre clé niveau Manifestation-->
            <xsl:for-each
                select="marc:datafield[@tag = '530'][marc:subfield[@code = 'a' and text() != '']]">
                <Entite>
                    <xsl:attribute name="id" select="concat($racineId, '/m/nomen/cle')"/>
                    <type lrm="NOMEN">NOMEN</type>
                    <type>TITRE</type>
                    <type>TITRE_CLE</type>
                    <propriete nom="TYPE_ACCES">paa</propriete>
                    <propriete nom="VALEUR">
                        <xsl:value-of
                            select="normalize-space(marc:subfield[@code = 'a' and text() != ''])"/>
                    </propriete>
                    <xsl:if test="marc:datafield[@tag = '530']/marc:subfield[@code = 'b'] != ''">
                        <propriete nom="QUALIFICATIF">
                            <xsl:value-of
                                select="normalize-space(marc:datafield[@tag = '530']/marc:subfield[@code = 'b'])"
                            />
                        </propriete>
                    </xsl:if>
                    <xsl:for-each
                        select="marc:datafield[@tag = '530']/marc:subfield[@code = '7' and text() != '']">
                        <propriete nom="ALPHABET">
                            <xsl:call-template name="codeEcriture">
                                <xsl:with-param name="code" select="."/>
                            </xsl:call-template>
                        </propriete>
                    </xsl:for-each>
                    <xsl:call-template name="meta">
                        <xsl:with-param name="idSource" select="$PPN"/>
                    </xsl:call-template>
                </Entite>
            </xsl:for-each>
            <xsl:comment>---- Entite Item ----</xsl:comment>
            <xsl:for-each-group
                select="marc:datafield[marc:subfield[@code = '5' and string-length(.) > 10]]"
                group-by="marc:subfield[@code = '5']">
                <xsl:variable name="EPN">
                    <xsl:value-of select="substring-after(marc:subfield[@code = '5'][1], ':')"/>
                </xsl:variable>
                <xsl:variable name="RCR">
                    <xsl:value-of select="substring-before(current-grouping-key(), ':')"/>
                </xsl:variable>
                <xsl:variable name="idItem" select="concat($racineId, '/i/', $EPN)"/>
                <xsl:if test="$RCR != ''">
                    <Entite id="{$idItem}">
                        <xsl:choose>
                            <xsl:when test="$typePub = 'MONOGRAPHIE'">
                                <type lrm="ITEM">ITEM</type>
                            </xsl:when>
                            <xsl:otherwise>
                                <type lrm="ITEM_AGREGATIF">ITEM_AGREGATIF</type>
                            </xsl:otherwise>
                        </xsl:choose>
                        <xsl:comment>---propriétés niveau Item ----</xsl:comment>
                        <xsl:for-each select="current-group()[@tag = '915']">
                            <xsl:for-each
                                select="marc:datafield[@tag = '856'][not(marc:subfield[@code = '5'])]">
                                <propriete nom="URI">
                                    <xsl:value-of select="."/>
                                </propriete>
                            </xsl:for-each>
                            <xsl:for-each select="marc:subfield[@code = 'a' and text() != '']">
                                <propriete nom="INVENTAIRE">
                                    <xsl:value-of select="."/>
                                </propriete>
                            </xsl:for-each>
                            <xsl:for-each select="marc:subfield[@code = 'b' and text() != '']">
                                <propriete nom="CODE_BARRES">
                                    <xsl:value-of select="."/>
                                </propriete>
                            </xsl:for-each>
                        </xsl:for-each>
                        <xsl:for-each select="current-group()[@tag = '930']">
                            <xsl:for-each select="marc:subfield[@code = 'a' and text() != '']">
                                <propriete nom="COTE">
                                    <xsl:value-of select="."/>
                                </propriete>
                            </xsl:for-each>
                            <xsl:for-each select="marc:subfield[@code = 'j' and text() != '']">
                                <propriete nom="CODE_PEB">
                                    <xsl:value-of select="."/>
                                </propriete>
                            </xsl:for-each>
                        </xsl:for-each>
                        <xsl:for-each select="marc:subfield[@code = 'p']">
                            <xsl:comment>--- l'item est dans le pcp dans le cadre d'un pôle de conservation ou pôle associé ---</xsl:comment>
                            <propriete nom="TYPE_POLE_PCP">
                                <xsl:value-of select="."/>
                            </propriete>
                        </xsl:for-each>
                        <xsl:call-template name="meta">
                            <xsl:with-param name="idSource" select="$PPN"/>
                        </xsl:call-template>
                        <xsl:comment>--- relations niveau Item ----</xsl:comment>
                        <xsl:comment>--- relation à la collectivité RCR détentrice via 930 $5 ---</xsl:comment>
                        <!--<relation> à remplacer par contribution role "possesseur"
                        <xsl:attribute name="xref" select="concat('http://www.abes.fr/rcr/', $RCR)"/>
                        <type>EST_POSSEDE_PAR</type>
                        <xsl:call-template name="meta"/>
                    </relation>-->
                        <xsl:if test="$RCR != ''">
                            <xsl:comment>--- RCR en tant qu'agent (contributeur) : quel rôle : localisation, possesseur, dépositaire ---</xsl:comment>
                            <xsl:call-template name="contrib_relation_rcr">
                                <xsl:with-param name="RCR" select="$RCR"/>
                            </xsl:call-template>
                            <xsl:comment>--- RCR en tant que fonds ---</xsl:comment>
                            <relation>
                                <xsl:variable name="xref"
                                    select="concat('http://www.abes.fr/rcr/', $RCR, '/fonds')"/>
                                <xsl:attribute name="xref">
                                    <xsl:value-of select="$xref"/>
                                </xsl:attribute>
                                <type>FAIT_PARTIE_DE</type>
                                <xsl:call-template name="meta"/>
                            </relation>
                        </xsl:if>
                        <xsl:for-each
                            select="current-group()[@tag = '930']/marc:subfield[@code = 'z' and text() != '']">
                            <relation>
                                <xsl:attribute name="xref"
                                    select="concat('http://www.abes.fr/pcp/', normalize-space(lower-case(.)))"/>
                                <!--<type>APPARTIENT_AU_PCP</type>-->
                                <type>FAIT_PARTIE_DE</type>
                                <xsl:call-template name="meta"/>
                            </relation>
                        </xsl:for-each>
                        <!-- RELATION Contributeurs (niveau items) -->
                        <xsl:variable name="roles">280 - 320 - 340 - 390 - 610 - 650 -
                            730</xsl:variable>
                        <xsl:for-each
                            select="current-group()[starts-with(@tag, '7')][marc:subfield[@code = '4'][contains($roles, text())]]">
                            <!--<xsl:variable name="codefct" select="marc:subfield[@code = '4']"/>-->
                            <!--                        <xsl:comment>valeur $codefct : <xsl:value-of select="$codefct"/></xsl:comment>-->
                            <xsl:choose>
                                <xsl:when test="marc:subfield[@code = '3']">
                                    <xsl:comment>---relation contributeur niveau Item ----</xsl:comment>
                                    <xsl:call-template name="contrib_relation">
                                        <xsl:with-param name="PPN" select="$PPN"/>
                                        <xsl:with-param name="mode" select="'relation_agent'"/>
                                        <!--<xsl:with-param name="codefct" select="$codefct"/>-->
                                    </xsl:call-template>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:comment>---- mention contributeur niveau Item ----</xsl:comment>
                                    <xsl:for-each
                                        select="current()[not(marc:subfield[@code = '3'])]">
                                        <xsl:variable name="key5">
                                            <xsl:value-of select="marc:subfield[@code = '5']"/>
                                        </xsl:variable>
                                        <xsl:variable name="position"
                                            select="count(preceding-sibling::marc:datafield[starts-with(@tag, '7')][marc:subfield[@code = '5'] = $key5 and not(marc:subfield[@code = '3'])]) + 1"/>
                                        <xsl:variable name="idMention"
                                            select="concat($racineId, '/m/contexte/', $position)"/>
                                        <!--<xsl:variable name="position" select="position()"/>
                                    <xsl:comment>valeur position : <xsl:value-of select="$position"/></xsl:comment>
                                    <xsl:comment>valeur idItem : <xsl:value-of select="$idItem"/></xsl:comment>-->
                                        <xsl:variable name="idMention"
                                            select="concat($idItem, '/contexte/', $position)"/>
                                        <xsl:call-template name="contrib_relation">
                                            <xsl:with-param name="mode" select="'relation_mention'"/>
                                            <xsl:with-param name="PPN" select="$PPN"/>
                                            <xsl:with-param name="idMention" select="$idMention"/>
                                            <xsl:with-param name="position" select="$position"/>
                                            <!--<xsl:with-param name="codefct" select="$codefct"/>-->
                                        </xsl:call-template>
                                    </xsl:for-each>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:for-each>
                        <!-- RELATION CONTRIB COMMENTEE PAR ERM  -->
                        <!--  <xsl:variable name="roles"
                        >390 - 610 - 320 - 340 - 650 - 280 - 730</xsl:variable>
                    <xsl:for-each select="current-group()[starts-with(@tag, '7')]">
                        <xsl:for-each
                            select="marc:subfield[@code = '3'][contains($roles, marc:subfield[@code = '4'])]">
                            <xsl:comment>-\-\-relation contributeur niveau Item -\-\-\-</xsl:comment>
                            <relation>
                                <xsl:variable name="idref"
                                    select="concat('http://www.idref.fr/', .)"/>
                                <xsl:attribute name="xref">
                                    <xsl:value-of select="$idref"/>
                                </xsl:attribute>
                                <type>A_POUR_CONTRIBUTEUR</type>
                                <xsl:call-template name="meta"/>
                                <xsl:call-template name="role">
                                    <xsl:with-param name="codefct"
                                        select="parent::marc:datafield/marc:subfield[@code = '4']"/>
                                </xsl:call-template>
                            </relation>
                        </xsl:for-each>
                    </xsl:for-each>
                    <!-\- RELATION pour mention contributeur niveau Item-\->
                    <xsl:for-each select="current-group()[starts-with(@tag, '7')]">
                        <xsl:comment>valeur position : <xsl:value-of select="position()"/></xsl:comment>
                        <xsl:variable name="position" select="position()"/>
                        <xsl:for-each
                            select=".[not(marc:subfield/@code = '3')][contains($roles, marc:subfield[@code = '4'])]">
                            <xsl:variable name="idMention"
                                select="concat($idItem, '/contexte/', $position)"/>
                            <xsl:comment>-\-\-\- mention contributeur niveau Item -\-\-\-</xsl:comment>
                            <relation>
                                <type>A_POUR_MENTION</type>
                                <xsl:call-template name="meta"/>
                                <Entite id="{$idMention}">
                                    <type lrm="CONTEXTE">CONTEXTE</type>
                                            <type>CONTRIBUTION</type>
                                    <xsl:call-template name="meta">
                                        <xsl:with-param name="idSource" select="$PPN"/>
                                    </xsl:call-template>
                                    <xsl:choose>
                                        <xsl:when
                                            test="parent::marc:datafield/marc:subfield[@code = '4'] != ''">
                                            <xsl:call-template name="role">
                                                <xsl:with-param name="codefct"
                                                  select="parent::marc:datafield/marc:subfield[@code = '4']"
                                                />
                                            </xsl:call-template>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <propriete nom="ROLE">Contributeur</propriete>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                    <relation xref="{$idMention}/contrib/nomen">
                                        <type>A_POUR_MENTION_DE_CONTRIBUTEUR</type>
                                        <xsl:call-template name="meta"/>
                                    </relation>
                                </Entite>
                            </relation>
                        </xsl:for-each>
                    </xsl:for-each>-->
                    </Entite>
                </xsl:if>
                <xsl:variable name="RCR">
                    <xsl:value-of select="substring-before(current-grouping-key(), ':')"/>
                </xsl:variable>
                <xsl:comment>--- Entité RCR en tant qu'agent (établissement) ---</xsl:comment>
                <xsl:if test="$RCR != ''">
                    <Entite>
                        <xsl:attribute name="id" select="concat('http://www.abes.fr/rcr/', $RCR)"/>
                        <type lrm="AGENT">AGENT</type>
                        <type>COLLECTIVITE</type>
                        <xsl:call-template name="meta">
                            <xsl:with-param name="idSource" select="$RCR"/>
                        </xsl:call-template>
                    </Entite>
                    <xsl:comment>--- Entité RCR en tant que fonds (ensemble, catalogue de documents) ---</xsl:comment>
                    <Entite>
                        <xsl:attribute name="id"
                            select="concat('http://www.abes.fr/rcr/', $RCR, '/fonds')"/>
                        <type lrm="ENSEMBLE">ENSEMBLE</type>
                        <type>FONDS</type>
                        <xsl:call-template name="contrib_relation_rcr">
                            <xsl:with-param name="RCR" select="$RCR"/>
                        </xsl:call-template>
                        <xsl:call-template name="meta">
                            <xsl:with-param name="idSource" select="$RCR"/>
                        </xsl:call-template>
                    </Entite>
                </xsl:if>
                <xsl:for-each
                    select="current-group()[@tag = '930']/marc:subfield[@code = 'z' and text() != '']">
                    <Entite>
                        <xsl:attribute name="id"
                            select="concat('http://www.abes.fr/pcp/', normalize-space(lower-case(.)))"/>
                        <type lrm="ENSEMBLE">ENSEMBLE</type>
                        <type>PCP</type>
                        <propriete nom="codePCP">
                            <xsl:value-of select="."/>
                        </propriete>
                        <xsl:call-template name="meta">
                            <xsl:with-param name="idSource"/>
                        </xsl:call-template>
                    </Entite>
                </xsl:for-each>
            </xsl:for-each-group>
            <!-- Titre de l'expression (le cas échéant) -->
            <xsl:for-each
                select="marc:datafield[@tag = '101']/marc:subfield[@code = 'a' and text() != '']">
                <xsl:variable name="langue">
                    <xsl:value-of select="normalize-space(.)"/>
                </xsl:variable>
                <xsl:for-each
                    select="ancestor::marc:record/marc:datafield[@tag = '510'][marc:subfield[@code = 'a' and text() != ''] and marc:subfield[@code = 'z'] = $langue]">
                    <Entite>
                        <xsl:attribute name="id" select="concat($racineId, '/e/nomen/', position())"/>
                        <type lrm="NOMEN">NOMEN</type>
                        <type>TITRE</type>
                        <propriete nom="TYPE_VALEUR">
                            <xsl:value-of select="normalize-space(marc:subfield[@code = 'a'])"/>
                        </propriete>
                        <xsl:for-each select="marc:subfield[@code = 'z']">
                            <propriete nom="LANGUE">
                                <xsl:call-template name="codeLangue">
                                    <xsl:with-param name="code" select="normalize-space(.)"/>
                                </xsl:call-template>
                                <!--<xsl:value-of select="normalize-space(.)"/>-->
                            </propriete>
                        </xsl:for-each>
                        <xsl:call-template name="meta">
                            <xsl:with-param name="idSource" select="$PPN"/>
                        </xsl:call-template>
                    </Entite>

                </xsl:for-each>
            </xsl:for-each>
            <!-- Entités de regroupepement (notices 579 et 500). Pour les 500, si pas de lien, on fait un nomen titre supplémentaire-->
            <xsl:if test="$TR = 'FALSE'">
                <xsl:for-each select="marc:datafield[@tag = '500']">
                    <Entite>
                        <xsl:choose>
                            <xsl:when test="marc:subfield[@code = '3'] != ''">
                                <xsl:attribute name="id"
                                    select="concat('http://www.idref.fr/', marc:subfield[@code = '3'])"/>
                                <type lrm="ENSEMBLE">ENSEMBLE</type>
                                <type>OEUVRES500</type>
                                <xsl:call-template name="meta">
                                    <xsl:with-param name="idSource"
                                        select="marc:subfield[@code = '3']"/>
                                    <xsl:with-param name="citeDans" select="$PPN"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="marc:subfield[@code = 'a'] != ''">
                                <xsl:attribute name="id"
                                    select="concat($racineId, '/w/500/nomen', position())"/>
                                <type lrm="NOMEN">NOMEN</type>
                                <type>TITRE</type>
                                <type>TITRE_UNIFORME</type>
                                <propriete nom="TYPE_ACCES">paa</propriete>
                                <propriete nom="VALEUR">
                                    <xsl:value-of
                                        select="normalize-space(marc:subfield[@code = 'a'])"/>
                                    <xsl:for-each
                                        select="marc:subfield[@code = 'i' and text() != '']">
                                        <xsl:value-of select="concat(' : ', normalize-space(.))"/>
                                    </xsl:for-each>
                                </propriete>
                                <xsl:for-each select="marc:subfield[@code = '7' and text() != '']">
                                    <propriete nom="ALPHABET">
                                        <xsl:comment>valeur code alphabet <xsl:value-of select="."/></xsl:comment>
                                        <xsl:call-template name="codeEcriture">
                                            <xsl:with-param name="code" select="."/>
                                        </xsl:call-template>
                                    </propriete>
                                </xsl:for-each>
                                <xsl:for-each select="marc:subfield[@code = 'm']">
                                    <propriete nom="LANGUE">
                                        <xsl:call-template name="codeLangue">
                                            <xsl:with-param name="code" select="normalize-space(.)"
                                            />
                                        </xsl:call-template>
                                        <!--<xsl:value-of select="normalize-space(.)"/>-->
                                    </propriete>
                                </xsl:for-each>
                                <xsl:call-template name="meta">
                                    <xsl:with-param name="idSource" select="$PPN"/>
                                    <xsl:with-param name="citeDans" select="$PPN"/>
                                </xsl:call-template>
                            </xsl:when>
                        </xsl:choose>
                    </Entite>
                </xsl:for-each>
            </xsl:if>
            <!--<xsl:for-each
                select="marc:datafield[@tag = '579']/marc:subfield[@code = '3' and text() != '']">
                <Entite>
                    <xsl:attribute name="id" select="concat('http://www.idref.fr/', .)"/>
                    <type lrm="ENSEMBLE">ENSEMBLE</type>
                    <type>OEUVRES579</type>

                    <xsl:call-template name="meta">
                        <xsl:with-param name="idSource" select="marc:subfield[@code = '3']"/>
                        <xsl:with-param name="citeDans" select="$PPN"/>
                    </xsl:call-template>
                </Entite>
            </xsl:for-each>-->
            <xsl:comment>---- nomen titre de l'oeuvre ----</xsl:comment>
            <!-- ENTITE Titre 
                    3/ en 200 value = concat a$ + si $e  : $e + si $f /$f + si $g ; $g
          -->
            <xsl:for-each
                select="marc:datafield[@tag = '200'][marc:subfield[@code = 'a' and text() != '']][$TR = 'false']">
                <Entite>
                    <xsl:attribute name="id" select="concat($racineId, '/w/nomen/', position())"/>
                    <type lrm="NOMEN">NOMEN</type>
                    <type>TITRE</type>
                    <propriete nom="TYPE_ACCES">ng</propriete>
                    <propriete nom="VALEUR">
                        <xsl:for-each
                            select="marc:subfield[@code = 'a' or @code = 'e' or @code = 'h' or @code = 'i' and text() != '']">
                            <xsl:choose>
                                <xsl:when test="@code = 'a'">
                                    <xsl:if
                                        test="count(preceding-sibling::marc:subfield[@code = 'a']) > 0">
                                        <xsl:text>.&#x20;</xsl:text>
                                    </xsl:if>
                                    <xsl:value-of select="normalize-space(.)"/>
                                </xsl:when>
                                <xsl:when test="@code = 'e'">
                                    <xsl:value-of select="concat(' : ', normalize-space())"/>
                                </xsl:when>
                                <xsl:when test="@code = 'h'">
                                    <xsl:value-of select="concat('. ', normalize-space())"/>
                                </xsl:when>
                                <xsl:when test="@code = 'i'">
                                    <xsl:value-of select="concat(', ', normalize-space())"/>
                                </xsl:when>
                            </xsl:choose>
                        </xsl:for-each>
                        <xsl:for-each select="marc:subfield[@code = 'f' and text() != '']">
                            <xsl:value-of select="concat(' / ', normalize-space(.))"/>
                        </xsl:for-each>
                        <xsl:for-each select="marc:subfield[@code = 'g' and text() != '']">
                            <xsl:value-of select="concat(' ; ', normalize-space(.))"/>
                        </xsl:for-each>
                    </propriete>
                    <xsl:for-each select="marc:subfield[@code = '7' and text() != '']">
                        <propriete nom="ALPHABET">
                            <xsl:comment>valeur code alphabet <xsl:value-of select="."/></xsl:comment>
                            <xsl:call-template name="codeEcriture">
                                <xsl:with-param name="code" select="."/>
                            </xsl:call-template>
                        </propriete>
                    </xsl:for-each>
                    <xsl:if
                        test="not(marc:subfield[@code = '6']) and parent::marc:datafield[@tag = '101'][marc:subfield[@code = 'g'] != '']">
                        <xsl:for-each
                            select="parent::marc:datafield[@tag = '101']/marc:subfield[@code = 'g']">
                            <propriete nom="LANGUE">
                                <xsl:call-template name="codeLangue">
                                    <xsl:with-param name="code" select="normalize-space(.)"/>
                                </xsl:call-template>
                                <!--<xsl:value-of select="normalize-space(.)"/>-->
                            </propriete>
                        </xsl:for-each>
                    </xsl:if>
                    <xsl:call-template name="meta">
                        <xsl:with-param name="idSource" select="$PPN"/>
                    </xsl:call-template>
                </Entite>
            </xsl:for-each>
            <!-- Nomen titre(s) de la manifestation -->
            <!-- Titre propre -->
            <xsl:for-each
                select="marc:datafield[@tag = '200']/marc:subfield[@code = 'a' and text() != '']">
                <Entite>
                    <xsl:attribute name="id" select="concat($racineId, '/m/nomen/', position())"/>
                    <type lrm="NOMEN">NOMEN</type>
                    <type>TITRE</type>
                    <type>TITRE_PROPRE</type>
                    <propriete nom="TYPE_ACCES">ng</propriete>
                    <propriete nom="VALEUR">
                        <xsl:value-of select="normalize-space(.)"/>
                    </propriete>
                    <xsl:for-each
                        select="parent::marc:datafield/marc:subfield[@code = '7' and text() != '']">
                        <propriete nom="ALPHABET">
                            <xsl:call-template name="codeEcriture">
                                <xsl:with-param name="code" select="."/>
                            </xsl:call-template>
                        </propriete>
                    </xsl:for-each>
                    <xsl:if
                        test="not(parent::marc:datafield/marc:subfield[@code = '6']) and parent::marc:datafield[@tag = '101'][marc:subfield[@code = 'g'] != '']">
                        <propriete nom="LANGUE">
                            <xsl:call-template name="codeLangue">
                                <xsl:with-param name="code"
                                    select="normalize-space(parent::marc:datafield[@tag = '101']/marc:subfield[@code = 'g'])"
                                />
                            </xsl:call-template>
                            <!--<xsl:value-of select="normalize-space(//marc:datafield[@tag = '101']/marc:subfield[@code = 'g'])"/>-->
                        </propriete>
                    </xsl:if>
                    <xsl:call-template name="meta">
                        <xsl:with-param name="idSource" select="$PPN"/>
                    </xsl:call-template>
                </Entite>
            </xsl:for-each>
            <!--ENTITE  Nomen identifiant-->
            <xsl:for-each
                select="marc:datafield[@tag = '011']/marc:subfield[@code = 'f'][text() != '']">
                <Entite>
                    <xsl:attribute name="id"
                        select="concat($racineId, '/w/nomen/identifiant/', position())"/>
                    <type lrm="NOMEN">NOMEN</type>
                    <type>ISSN-L</type>
                    <propriete nom="VALEUR">
                        <xsl:value-of select="normalize-space(text())"/>
                    </propriete>
                    <xsl:call-template name="meta">
                        <xsl:with-param name="idSource" select="$PPN"/>
                    </xsl:call-template>
                </Entite>
            </xsl:for-each>
            <xsl:comment>---- Relation 4XX niveau Oeuvre ----
            idSource : entite pointé
            citeDans : entite de départ
            </xsl:comment>
            <!-- ENTITE 430 A_POUR_SUITE-->
            <!--<xsl:for-each select="marc:datafield[(@tag = '430')]">
                <xsl:choose>
                    <!-\- 430 $0 A_POUR_SUITE-\->
                    <xsl:when test="marc:subfield[@code = '0']">
                        <Entite>
                            <xsl:attribute name="id"
                                select="concat('http://www.abes.fr/', marc:subfield[@code = '0'], '/w')"/>
                            <type lrm="OEUVRE_AGREGATIVE">OEUVRE_AGREGATIVE</type>
                            <type>PUBSERIE</type>
                            <xsl:call-template name="meta">
                                <xsl:with-param name="idSource" select="marc:subfield[@code = '0']"/>
                                <xsl:with-param name="citeDans" select="$PPN"/>
                            </xsl:call-template>
                        </Entite>
                    </xsl:when>
                    <!-\- 430 $t A_POUR_SUITE-\->
                    <xsl:when test="marc:subfield[@code = 't'][text() != '']">
                        <Entite>
                            <xsl:attribute name="id" select="concat($racineId, '/w/430/',position())"/>
                            <type lrm="OEUVRE_AGREGATIVE">OEUVRE_AGREGATIVE</type>
                            <type>PUBSERIE</type>
                            <xsl:call-template name="meta">
                                <xsl:with-param name="citeDans" select="$PPN"/>
                            </xsl:call-template>
                            <!-\-<xsl:for-each select="marc:subfield[@code = 'x']">
                                <propriete nom="ISSN">
                                    <xsl:value-of select="."/>
                                </propriete>
                            </xsl:for-each>-\->
                            <relation xref="{concat($racineId,'/w/430/nomen')}">
                                <type>A_POUR_NOMEN</type>
                                <xsl:call-template name="meta"/>
                            </relation>
                            <!-\-<xsl:if test="marc:subfield[@code = 'x']">
                                <relation xref="{concat($racineId,'/w/430/nomen/identifiant')}">
                                    <type>A_POUR_NOMEN</type>
                                    <xsl:call-template name="meta"/>
                                </relation>
                            </xsl:if>-\->
                        </Entite>
                        <Entite id="{concat($racineId,'/w/430/nomen')}">
                            <type lrm="NOMEN">NOMEN</type>
                            <type>TITRE</type>
                            <propriete nom="TYPE_ACCES">ng</propriete>
                            <propriete nom="VALEUR">
                                <xsl:value-of select="normalize-space(marc:subfield[@code = 't'])"/>
                            </propriete>
                            <xsl:call-template name="meta">
                                <xsl:with-param name="idSource" select="$PPN"/>
                            </xsl:call-template>
                        </Entite>
                        <!-\-<xsl:if test="marc:subfield[@code = 'x']">
                            <Entite id="{concat($racineId,'/w/430/nomen/identifiant')}">
                                <type lrm="NOMEN">NOMEN</type>
                                <type>IDENTIFIANT</type>
                                <propriete nom="TYPE_ACCES">ng</propriete>
                                <propriete nom="VALEUR">
                                    <xsl:value-of
                                        select="normalize-space(marc:subfield[@code = 'x'])"/>
                                </propriete>
                                <xsl:call-template name="meta">
                                    <xsl:with-param name="idSource" select="$PPN"/>
                                </xsl:call-template>
                            </Entite>
                        </xsl:if>-\->
                    </xsl:when>
                </xsl:choose>
            </xsl:for-each>-->
            <!-- ENTITE 440  EST_LA_SUITE_DE-->
            <!--<xsl:for-each select="marc:datafield[(@tag = '440')]">
                <xsl:choose>
                    <!-\- 440 $0 EST_LA_SUITE_DE-\->
                    <xsl:when test="marc:subfield[@code = '0']">
                        <Entite>
                            <xsl:attribute name="id"
                                select="concat('http://www.abes.fr/', marc:subfield[@code = '0'], '/w')"/>
                            <type lrm="OEUVRE_AGREGATIVE">OEUVRE_AGREGATIVE</type>
                            <type>PUBSERIE</type>
                            <xsl:call-template name="meta">
                                <xsl:with-param name="idSource" select="marc:subfield[@code = '0']"/>
                                <xsl:with-param name="citeDans" select="$PPN"/>
                            </xsl:call-template>
                        </Entite>
                    </xsl:when>
                    <!-\- 440 $t EST_LA_SUITE_DE-\->
                    <xsl:when test="marc:subfield[@code = 't'][text() != '']">
                        <Entite>
                            <xsl:attribute name="id" select="concat($racineId, '/w/440/',position())"/>
                            <type lrm="OEUVRE_AGREGATIVE">OEUVRE_AGREGATIVE</type>
                            <type>PUBSERIE</type>
                            <xsl:call-template name="meta">
                                <xsl:with-param name="idSource" select="$PPN"/>
                            </xsl:call-template>
                            <!-\-<xsl:for-each select="marc:subfield[@code = 'x']">
                                <propriete nom="ISSN">
                                    <xsl:value-of select="."/>
                                </propriete>
                            </xsl:for-each>-\->
                            <relation xref="{concat($racineId,'/w/440/nomen')}">
                                <type>A_POUR_NOMEN</type>
                                <xsl:call-template name="meta"/>
                            </relation>
                            <!-\-<xsl:if test="marc:subfield[@code = 'x']">
                                <relation xref="{concat($racineId,'/w/440/nomen/identifiant')}">
                                    <type>A_POUR_NOMEN</type>
                                    <xsl:call-template name="meta"/>
                                </relation>
                            </xsl:if>-\->
                        </Entite>
                        <Entite id="{concat($racineId,'/w/440/nomen')}">
                            <type lrm="NOMEN">NOMEN</type>
                            <type>TITRE</type>
                            <propriete nom="TYPE_ACCES">ng</propriete>
                            <propriete nom="VALEUR">
                                <xsl:value-of select="normalize-space(marc:subfield[@code = 't'])"/>
                            </propriete>
                            <xsl:call-template name="meta">
                                <xsl:with-param name="idSource" select="$PPN"/>
                            </xsl:call-template>
                        </Entite>
                        <!-\-  <xsl:if test="marc:subfield[@code = 'x']">
                            <Entite id="{concat($racineId,'/w/440/nomen/identifiant')}">
                                <type lrm="NOMEN">NOMEN</type>
                                <type>IDENTIFIANT</type>
                                <propriete nom="TYPE_ACCES">ng</propriete>
                                <propriete nom="VALEUR">
                                    <xsl:value-of
                                        select="normalize-space(marc:subfield[@code = 'x'])"/>
                                </propriete>
                                <xsl:call-template name="meta">
                                    <xsl:with-param name="idSource" select="$PPN"/>
                                </xsl:call-template>
                            </Entite>
                        </xsl:if>-\->
                    </xsl:when>
                </xsl:choose>
            </xsl:for-each>-->
            <!--  ENTITE 451 A_POUR_AUTRE_EDITION_MEME_SUPPORT-->
            <!--<xsl:for-each select="marc:datafield[(@tag = '451')]">
                <xsl:choose>
                    <!-\- entite 451$0 A_POUR_AUTRE_EDITION_MEME_SUPPORT-\->
                    <xsl:when test="marc:subfield[@code = '0']">
                        <!-\- Création d'une entité oeuvre "bidon" pour permettre le chargement dans Oracle (contrainte pas de manif sans oeuvre) -\->
                        <Entite>
                            <xsl:attribute name="id"
                                select="concat('http://www.abes.fr/', marc:subfield[@code = '0'], '/w')"/>
                            <xsl:choose>
                                <xsl:when test="$typePub = 'MONOGRAPHIE'">
                                    <type lrm="OEUVRE">OEUVRE</type>
                                </xsl:when>
                                <xsl:otherwise>
                                    <type lrm="OEUVRE_AGREGATIVE">OEUVRE_AGREGATIVE</type>
                                </xsl:otherwise>
                            </xsl:choose>
                            <type>
                                <xsl:value-of select="$typePub"/>
                            </type>
                            <relation>
                                <xsl:attribute name="xref"
                                    select="concat('http://www.abes.fr/', marc:subfield[@code = '0'], '/m')"/>
                                <type>A_POUR_MANIFESTATION</type>
                                <xsl:call-template name="meta"/>
                            </relation>
                            <xsl:call-template name="meta">
                                <xsl:with-param name="idSource" select="marc:subfield[@code = '0']"/>
                                <xsl:with-param name="citeDans" select="$PPN"/>
                            </xsl:call-template>
                        </Entite>
                        <Entite>
                            <xsl:attribute name="id"
                                select="concat('http://www.abes.fr/', marc:subfield[@code = '0'], '/m')"/>
                            <xsl:choose>
                                <xsl:when test="$typePub = 'MONOGRAPHIE'">
                                    <type lrm="MANIFESTATION">MANIFESTATION</type>
                                </xsl:when>
                                <xsl:otherwise>
                                    <type lrm="MANIFESTATION_AGREGATIVE"
                                        >MANIFESTATION_AGREGATIVE</type>
                                </xsl:otherwise>
                            </xsl:choose>
                            <type>
                                <xsl:value-of select="$typePub"/>
                            </type>
                            <xsl:call-template name="meta">
                                <xsl:with-param name="idSource" select="marc:subfield[@code = '0']"/>
                                <xsl:with-param name="citeDans" select="$PPN"/>
                            </xsl:call-template>
                        </Entite>
                    </xsl:when>
                    <!-\- entite 451$t  A_POUR_AUTRE_EDITION_MEME_SUPPORT-\->
                    <xsl:when test="marc:subfield[@code = 't'][text() != '']">
                        <!-\- Création d'une entité oeuvre "bidon" pour permettre le chargement dans Oracle (contrainte pas de manif sans oeuvre) -\->
                        <Entite>
                            <xsl:attribute name="id" select="concat($racineId, '/w/451/',position())"/>
                            <xsl:choose>
                                <xsl:when test="$typePub = 'MONOGRAPHIE'">
                                    <type lrm="OEUVRE">OEUVRE</type>
                                </xsl:when>
                                <xsl:otherwise>
                                    <type lrm="OEUVRE_AGREGATIVE">OEUVRE_AGREGATIVE</type>
                                </xsl:otherwise>
                            </xsl:choose>
                            <type>
                                <xsl:value-of select="$typePub"/>
                            </type>
                            <relation>
                                <xsl:attribute name="xref" select="concat($racineId, '/m/451/',position())"/>
                                <type>A_POUR_MANIFESTATION</type>
                                <xsl:call-template name="meta"/>
                            </relation>
                            <xsl:call-template name="meta">
                                <xsl:with-param name="idSource" select="$PPN"/>
                            </xsl:call-template>
                        </Entite>
                        <Entite>
                            <xsl:attribute name="id" select="concat($racineId, '/m/451/',position())"/>
                            <xsl:choose>
                                <xsl:when test="$typePub = 'MONOGRAPHIE'">
                                    <type lrm="MANIFESTATION">MANIFESTATION</type>
                                </xsl:when>
                                <xsl:otherwise>
                                    <type lrm="MANIFESTATION_AGREGATIVE"
                                        >MANIFESTATION_AGREGATIVE</type>
                                </xsl:otherwise>
                            </xsl:choose>
                            <type>
                                <xsl:value-of select="$typePub"/>
                            </type>
                            <xsl:call-template name="meta">
                                <xsl:with-param name="idSource" select="$PPN"/>
                            </xsl:call-template>
                            <xsl:for-each select="marc:subfield[@code = 'x'][text() != '']">
                                <propriete nom="ISSN">
                                    <xsl:value-of select="normalize-space(.)"/>
                                </propriete>
                            </xsl:for-each>
                            <xsl:for-each select="marc:subfield[@code = 'y'][text() != '']">
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
                            </xsl:for-each>
                            <relation xref="{concat($racineId,'/m/451/',position(),'/nomen')}">
                                <type>A_POUR_NOMEN</type>
                                <xsl:call-template name="meta"/>
                            </relation>
                        </Entite>
                        <Entite id="{concat($racineId,'/m/451/',position(),'/nomen')}">
                            <type lrm="NOMEN">NOMEN</type>
                            <type>TITRE</type>
                            <propriete nom="TYPE_ACCES">ng</propriete>
                            <propriete nom="VALEUR">
                                <xsl:value-of select="normalize-space(marc:subfield[@code = 't'])"/>
                            </propriete>
                            <xsl:call-template name="meta">
                                <xsl:with-param name="idSource" select="$PPN"/>
                            </xsl:call-template>
                        </Entite>
                    </xsl:when>
                </xsl:choose>
            </xsl:for-each>-->
            <!-- ENTITE 452 A_POUR_AUTRE_EDITION_SUPPORT_DIFFERENT-->
            <!--<xsl:for-each select="marc:datafield[(@tag = '452')]">
                <xsl:choose>
                    <!-\- entite 452$0 A_POUR_AUTRE_EDITION_SUPPORT_DIFFERENT-\->
                    <xsl:when test="marc:subfield[@code = '0']">
                        <!-\- Création d'une entité oeuvre "bidon" pour permettre le chargement dans Oracle (contrainte pas de manif sans oeuvre) -\->
                        <Entite>
                            <xsl:attribute name="id"
                                select="concat('http://www.abes.fr/', marc:subfield[@code = '0'], '/w')"/>
                            <xsl:choose>
                                <xsl:when test="$typePub = 'MONOGRAPHIE'">
                                    <type lrm="OEUVRE">OEUVRE</type>
                                </xsl:when>
                                <xsl:otherwise>
                                    <type lrm="OEUVRE_AGREGATIVE">OEUVRE_AGREGATIVE</type>
                                </xsl:otherwise>
                            </xsl:choose>
                            <type>
                                <xsl:value-of select="$typePub"/>
                            </type>
                            <relation>
                                <xsl:attribute name="xref"
                                    select="concat('http://www.abes.fr/', marc:subfield[@code = '0'], '/m')"/>
                                <type>A_POUR_MANIFESTATION</type>
                                <xsl:call-template name="meta"/>
                            </relation>
                            <xsl:call-template name="meta">
                                <xsl:with-param name="idSource" select="marc:subfield[@code = '0']"/>
                                <xsl:with-param name="citeDans" select="$PPN"/>
                            </xsl:call-template>
                        </Entite>
                        <Entite>
                            <xsl:attribute name="id"
                                select="concat('http://www.abes.fr/', marc:subfield[@code = '0'], '/m')"/>
                            <xsl:choose>
                                <xsl:when test="$typePub = 'MONOGRAPHIE'">
                                    <type lrm="MANIFESTATION">MANIFESTATION</type>
                                </xsl:when>
                                <xsl:otherwise>
                                    <type lrm="MANIFESTATION_AGREGATIVE"
                                        >MANIFESTATION_AGREGATIVE</type>
                                </xsl:otherwise>
                            </xsl:choose>
                            <type>
                                <xsl:value-of select="$typePub"/>
                            </type>
                            <xsl:call-template name="meta">
                                <xsl:with-param name="idSource" select="marc:subfield[@code = '0']"/>
                                <xsl:with-param name="citeDans" select="$PPN"/>
                            </xsl:call-template>
                        </Entite>
                    </xsl:when>
                    <!-\- entite 452$t  A_POUR_AUTRE_EDITION_SUPPORT_DIFFERENT-\->
                    <xsl:when test="marc:subfield[@code = 't'][text() != '']">
                        <!-\- Création d'une entité oeuvre "bidon" pour permettre le chargement dans Oracle (contrainte pas de manif sans oeuvre) -\->
                        <Entite>
                            <xsl:attribute name="id" select="concat($racineId, '/w/452/',position())"/>
                            <xsl:choose>
                                <xsl:when test="$typePub = 'MONOGRAPHIE'">
                                    <type lrm="OEUVRE">OEUVRE</type>
                                </xsl:when>
                                <xsl:otherwise>
                                    <type lrm="OEUVRE_AGREGATIVE">OEUVRE_AGREGATIVE</type>
                                </xsl:otherwise>
                            </xsl:choose>
                            <type>
                                <xsl:value-of select="$typePub"/>
                            </type>
                            <relation>
                                <xsl:attribute name="xref" select="concat($racineId, '/w/452/',position())"/>
                                <type>A_POUR_MANIFESTATION</type>
                                <xsl:call-template name="meta"/>
                            </relation>
                            <xsl:call-template name="meta">
                                <xsl:with-param name="idSource" select="$PPN"/>
                            </xsl:call-template>
                        </Entite>
                        <Entite>
                            <xsl:attribute name="id" select="concat($racineId, '/w/452/',position())"/>
                            <xsl:choose>
                                <xsl:when test="$typePub = 'MONOGRAPHIE'">
                                    <type lrm="MANIFESTATION">MANIFESTATION</type>
                                </xsl:when>
                                <xsl:otherwise>
                                    <type lrm="MANIFESTATION_AGREGATIVE"
                                        >MANIFESTATION_AGREGATIVE</type>
                                </xsl:otherwise>
                            </xsl:choose>
                            <type>
                                <xsl:value-of select="$typePub"/>
                            </type>
                            <xsl:call-template name="meta">
                                <xsl:with-param name="idSource" select="$PPN"/>
                            </xsl:call-template>
                            <xsl:for-each select="marc:subfield[@code = 'x'][text() != '']">
                                <propriete nom="ISSN">
                                    <xsl:value-of select="normalize-space(.)"/>
                                </propriete>
                            </xsl:for-each>
                            <xsl:for-each select="marc:subfield[@code = 'y'][text() != '']">
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
                            </xsl:for-each>
                            <relation xref="{concat($racineId,'/m/452/',position(),'/nomen')}">
                                <type>A_POUR_NOMEN</type>
                                <xsl:call-template name="meta"/>
                            </relation>
                        </Entite>
                        <Entite id="{concat($racineId,'/m/452/',position(),'/nomen)}">
                            <type lrm="NOMEN">NOMEN</type>
                            <type>TITRE</type>
                            <propriete nom="TYPE_ACCES">ng</propriete>
                            <propriete nom="VALEUR">
                                <xsl:value-of select="normalize-space(marc:subfield[@code = 't'])"/>
                            </propriete>
                            <xsl:call-template name="meta">
                                <xsl:with-param name="idSource" select="$PPN"/>
                            </xsl:call-template>
                        </Entite>
                    </xsl:when>
                </xsl:choose>
            </xsl:for-each>-->
            <!--  ENTITE 455 EST_UNE_REPRODUCTION_DE-->
            <!--<xsl:for-each select="marc:datafield[(@tag = '455')]">
                <xsl:choose>
                    <!-\- entite 455$0 EST_UNE_REPRODUCTION_DE-\->
                    <xsl:when test="marc:subfield[@code = '0']">
                        <!-\- Création d'une entité oeuvre "bidon" pour permettre le chargement dans Oracle (contrainte pas de manif sans oeuvre) -\->
                        <Entite>
                            <xsl:attribute name="id"
                                select="concat('http://www.abes.fr/', marc:subfield[@code = '0'], '/w')"/>
                            <xsl:choose>
                                <xsl:when test="$typePub = 'MONOGRAPHIE'">
                                    <type lrm="OEUVRE">OEUVRE</type>
                                </xsl:when>
                                <xsl:otherwise>
                                    <type lrm="OEUVRE_AGREGATIVE">OEUVRE_AGREGATIVE</type>
                                </xsl:otherwise>
                            </xsl:choose>
                            <type>
                                <xsl:value-of select="$typePub"/>
                            </type>
                            <relation>
                                <xsl:attribute name="xref"
                                    select="concat('http://www.abes.fr/', marc:subfield[@code = '0'], '/m')"/>
                                <type>A_POUR_MANIFESTATION</type>
                                <xsl:call-template name="meta"/>
                            </relation>
                            <xsl:call-template name="meta">
                                <xsl:with-param name="idSource" select="marc:subfield[@code = '0']"/>
                                <xsl:with-param name="citeDans" select="$PPN"/>
                            </xsl:call-template>
                        </Entite>
                        <Entite>
                            <xsl:attribute name="id"
                                select="concat('http://www.abes.fr/', marc:subfield[@code = '0'], '/m')"/>
                            <xsl:choose>
                                <xsl:when test="$typePub = 'MONOGRAPHIE'">
                                    <type lrm="MANIFESTATION">MANIFESTATION</type>
                                </xsl:when>
                                <xsl:otherwise>
                                    <type lrm="MANIFESTATION_AGREGATIVE"
                                        >MANIFESTATION_AGREGATIVE</type>
                                </xsl:otherwise>
                            </xsl:choose>
                            <type>
                                <xsl:value-of select="$typePub"/>
                            </type>
                            <xsl:call-template name="meta">
                                <xsl:with-param name="idSource" select="marc:subfield[@code = '0']"/>
                                <xsl:with-param name="citeDans" select="$PPN"/>
                            </xsl:call-template>
                        </Entite>
                    </xsl:when>
                    <!-\- entite 455$t  EST_UNE_REPRODUCTION_DE-\->
                    <xsl:when test="marc:subfield[@code = 't'][text() != '']">
                        <!-\- Création d'une entité oeuvre "bidon" pour permettre le chargement dans Oracle (contrainte pas de manif sans oeuvre) -\->
                        <Entite>
                            <xsl:attribute name="id" select="concat($racineId, '/w/455/',position())"/>
                            <xsl:choose>
                                <xsl:when test="$typePub = 'MONOGRAPHIE'">
                                    <type lrm="OEUVRE">OEUVRE</type>
                                </xsl:when>
                                <xsl:otherwise>
                                    <type lrm="OEUVRE_AGREGATIVE">OEUVRE_AGREGATIVE</type>
                                </xsl:otherwise>
                            </xsl:choose>
                            <type>
                                <xsl:value-of select="$typePub"/>
                            </type>
                            <relation>
                                <xsl:attribute name="xref" select="concat($racineId, '/m/455/',position())"/>
                                <type>A_POUR_MANIFESTATION</type>
                                <xsl:call-template name="meta"/>
                            </relation>
                            <xsl:call-template name="meta">
                                <xsl:with-param name="idSource" select="$PPN"/>
                            </xsl:call-template>
                        </Entite>
                        <Entite>
                            <xsl:attribute name="id" select="concat($racineId, '/m/455/',position())"/>
                            <xsl:choose>
                                <xsl:when test="$typePub = 'MONOGRAPHIE'">
                                    <type lrm="MANIFESTATION">MANIFESTATION</type>
                                </xsl:when>
                                <xsl:otherwise>
                                    <type lrm="MANIFESTATION_AGREGATIVE"
                                        >MANIFESTATION_AGREGATIVE</type>
                                </xsl:otherwise>
                            </xsl:choose>
                            <type>
                                <xsl:value-of select="$typePub"/>
                            </type>
                            <xsl:call-template name="meta">
                                <xsl:with-param name="idSource" select="$PPN"/>
                            </xsl:call-template>
                            <xsl:for-each select="marc:subfield[@code = 'x'][text() != '']">
                                <propriete nom="ISSN">
                                    <xsl:value-of select="normalize-space(.)"/>
                                </propriete>
                            </xsl:for-each>
                            <xsl:for-each select="marc:subfield[@code = 'y'][text() != '']">
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
                            </xsl:for-each>
                            <relation xref="{concat($racineId,'/m/455/',position(),'/nomen')}">
                                <type>A_POUR_NOMEN</type>
                                <xsl:call-template name="meta"/>
                            </relation>
                        </Entite>
                        <Entite id="{concat($racineId,'/m/455/',position(),'/nomen')}">
                            <type lrm="NOMEN">NOMEN</type>
                            <type>TITRE</type>
                            <propriete nom="TYPE_ACCES">ng</propriete>
                            <propriete nom="VALEUR">
                                <xsl:value-of select="normalize-space(marc:subfield[@code = 't'])"/>
                            </propriete>
                            <xsl:call-template name="meta">
                                <xsl:with-param name="idSource" select="$PPN"/>
                            </xsl:call-template>
                        </Entite>
                    </xsl:when>
                </xsl:choose>
            </xsl:for-each>-->
            <!--  ENTITE 410 EST_AGREGE_DANS -->
            <!--<xsl:for-each select="marc:datafield[(@tag = '410')]">
                <xsl:choose>
                    <!-\-  entite 410$0 EST_AGREGE_DANS -\->
                    <xsl:when test="marc:subfield[@code = '0']">
                        <!-\- Création d'une entité oeuvre "bidon" pour permettre le chargement dans Oracle (contrainte pas de manif sans oeuvre) -\->
                        <Entite>
                            <xsl:attribute name="id"
                                select="concat('http://www.abes.fr/', marc:subfield[@code = '0'], '/w')"/>
                            <type lrm="OEUVRE_AGREGATIVE">OEUVRE_AGREGATIVE</type>
                            <type>PUBSERIE</type>
                            <type>COLLECTION</type>
                            <relation>
                                <xsl:attribute name="xref"
                                    select="concat('http://www.abes.fr/', marc:subfield[@code = '0'], '/m')"/>
                                <type>A_POUR_MANIFESTATION</type>
                                <xsl:call-template name="meta"/>
                            </relation>
                            <xsl:call-template name="meta">
                                <xsl:with-param name="idSource" select="marc:subfield[@code = '0']"/>
                                <xsl:with-param name="citeDans" select="$PPN"/>
                            </xsl:call-template>
                        </Entite>
                        <Entite>
                            <xsl:attribute name="id"
                                select="concat('http://www.abes.fr/', marc:subfield[@code = '0'], '/m')"/>
                            <type lrm="MANIFESTATION_AGREGATIVE">MANIFESTATION_AGREGATIVE</type>
                            <type>PUBSERIE</type>
                            <type>COLLECTION</type>
                            <xsl:call-template name="meta">
                                <xsl:with-param name="idSource" select="marc:subfield[@code = '0']"/>
                                <xsl:with-param name="citeDans" select="$PPN"/>
                            </xsl:call-template>
                        </Entite>
                    </xsl:when>
                    <!-\-  entite 410$t EST_AGREGE_DANS-\->
                    <xsl:when test="marc:subfield[@code = 't'][text() != '']">
                        <!-\- Création d'une entité oeuvre "bidon" pour permettre le chargement dans Oracle (contrainte pas de manif sans oeuvre) -\->
                        <Entite>
                            <xsl:attribute name="id" select="concat($racineId, '/w/410')"/>
                            <type lrm="MANIFESTATION_AGREGATIVE">MANIFESTATION_AGREGATIVE</type>
                            <type>PUBSERIE</type>
                            <type>COLLECTION</type>
                            <relation>
                                <xsl:attribute name="xref" select="concat($racineId, '/m/410/',position())"/>
                                <type>A_POUR_MANIFESTATION</type>
                                <xsl:call-template name="meta"/>
                            </relation>
                            <xsl:call-template name="meta">
                                <xsl:with-param name="idSource" select="$PPN"/>
                            </xsl:call-template>
                        </Entite>
                        <Entite>
                            <xsl:attribute name="id" select="concat($racineId, '/m/410/',position())"/>
                            <type lrm="MANIFESTATION_AGREGATIVE">MANIFESTATION_AGREGATIVE</type>
                            <type>PUBSERIE</type>
                            <type>COLLECTION</type>
                            <xsl:call-template name="meta">
                                <xsl:with-param name="idSource" select="$PPN"/>
                            </xsl:call-template>
                            <xsl:for-each select="marc:subfield[@code = 'x'][text() != '']">
                                <propriete nom="ISSN">
                                    <xsl:value-of select="normalize-space(.)"/>
                                </propriete>
                            </xsl:for-each>
                            <relation xref="{concat($racineId,'/m/410/',position(),'/nomen')}">
                                <type>A_POUR_NOMEN</type>
                                <xsl:call-template name="meta"/>
                            </relation>
                        </Entite>
                        <Entite id="{concat($racineId,'/m/410/',position(),'/nomen')}">
                            <type lrm="NOMEN">NOMEN</type>
                            <type>TITRE</type>
                            <propriete nom="TYPE_ACCES">ng</propriete>
                            <propriete nom="VALEUR">
                                <xsl:value-of
                                    select="normalize-space(marc:subfield[@code = 't'][1])"/>
                            </propriete>
                            <xsl:call-template name="meta">
                                <xsl:with-param name="idSource" select="$PPN"/>
                            </xsl:call-template>
                        </Entite>
                    </xsl:when>
                </xsl:choose>
            </xsl:for-each>-->
            <!--  ENTITE 461 EST_AGREGE_DANS -->
            <!--<xsl:for-each select="marc:datafield[(@tag = '461')]">
                <xsl:choose>
                    <!-\-  entite 461$0 EST_AGREGE_DANS -\->
                    <xsl:when test="marc:subfield[@code = '0']">
                        <Entite>
                            <xsl:attribute name="id"
                                select="concat('http://www.abes.fr/', marc:subfield[@code = '0'], '/m')"/>
                            <type lrm="MANIFESTATION_AGREGATIVE">MANIFESTATION_AGREGATIVE</type>
                            <type>PUBSERIE</type>
                            <type>PERIODIQUE</type>
                            <xsl:call-template name="meta">
                                <xsl:with-param name="idSource" select="$PPN"/>
                            </xsl:call-template>
                            <xsl:for-each select="marc:subfield[@code = 'x'][text() != '']">
                                <propriete nom="ISSN">
                                    <xsl:value-of select="normalize-space(.)"/>
                                </propriete>
                            </xsl:for-each>
                            <relation
                                xref="{concat('http://www.abes.fr/', marc:subfield[@code = '0'], '/m')}">
                                <type>A_POUR_NOMEN</type>
                                <xsl:call-template name="meta"/>
                            </relation>
                        </Entite>
                        <Entite>
                            <xsl:attribute name="id"
                                select="concat('http://www.abes.fr/', marc:subfield[@code = '0'], '/m')"/>
                            <type lrm="MANIFESTATION_AGREGATIVE">MANIFESTATION_AGREGATIVE</type>
                            <type>PUBSERIE</type>
                            <type>PERIODIQUE</type>
                            <xsl:call-template name="meta">
                                <xsl:with-param name="idSource" select="marc:subfield[@code = '0']"/>
                                <xsl:with-param name="citeDans" select="$PPN"/>
                            </xsl:call-template>
                        </Entite>
                    </xsl:when>
                    <!-\-  entite 461$t EST_AGREGE_DANS-\->
                    <xsl:when test="marc:subfield[@code = 't'][text() != '']">
                        <!-\- Création d'une entité oeuvre "bidon" pour permettre le chargement dans Oracle (contrainte pas de manif sans oeuvre) -\->
                        <Entite>
                            <xsl:attribute name="id" select="concat($racineId, '/w/461/',position())"/>
                            <type lrm="MANIFESTATION_AGREGATIVE">OEUVRE_AGREGATIVE</type>
                            <type>PUBSERIE</type>
                            <type>COLLECTION</type>
                            <relation>
                                <xsl:attribute name="xref" select="concat($racineId, '/m/461/',position())"/>
                                <type>A_POUR_MANIFESTATION</type>
                                <xsl:call-template name="meta"/>
                            </relation>
                            <xsl:call-template name="meta">
                                <xsl:with-param name="idSource" select="$PPN"/>
                            </xsl:call-template>
                        </Entite>
                        <Entite>
                            <xsl:attribute name="id" select="concat($racineId, '/m/461/',position())"/>
                            <type lrm="MANIFESTATION_AGREGATIVE">MANIFESTATION_AGREGATIVE</type>
                            <xsl:call-template name="meta">
                                <xsl:with-param name="idSource" select="$PPN"/>
                            </xsl:call-template>
                            <xsl:for-each select="marc:subfield[@code = 'x'][text() != '']">
                                <propriete nom="ISSN">
                                    <xsl:value-of select="normalize-space(.)"/>
                                </propriete>
                            </xsl:for-each>
                            <relation xref="{concat($racineId,'/m/461/',position(),'/nomen')}">
                                <type>A_POUR_NOMEN</type>
                                <xsl:call-template name="meta"/>
                            </relation>
                        </Entite>
                        <Entite id="{concat($racineId,'/m/461/',position(),'/nomen')}">
                            <type lrm="NOMEN">NOMEN</type>
                            <type>TITRE</type>
                            <propriete nom="TYPE_ACCES">ng</propriete>
                            <propriete nom="VALEUR">
                                <xsl:value-of select="normalize-space(marc:subfield[@code = 't'])"/>
                            </propriete>
                            <xsl:call-template name="meta">
                                <xsl:with-param name="idSource" select="$PPN"/>
                            </xsl:call-template>
                        </Entite>
                    </xsl:when>
                </xsl:choose>
            </xsl:for-each>-->
            <!-- ENTITE 464 AGREGE (OEUVRE)-->
            <!--<xsl:if test="$TR = 'false'">
                <xsl:for-each select="marc:datafield[@tag = '464']">
                    <xsl:comment> test for-each 464 : <xsl:value-of select="position()"/></xsl:comment>
                    <xsl:choose>
                        <!-\- 464 $0 AGREGE-\->
                        <xsl:when test="marc:subfield[@code = '0']">
                            <Entite>
                                <xsl:attribute name="id"
                                    select="concat('http://www.abes.fr/', marc:subfield[@code = '0'], '/w')"/>
                                <type lrm="MANIFESTATION">MANIFESTATION</type>
                                <xsl:call-template name="meta">
                                    <xsl:with-param name="idSource"
                                        select="marc:subfield[@code = '0']"/>
                                    <xsl:with-param name="citeDans" select="$PPN"/>
                                </xsl:call-template>
                            </Entite>
                        </xsl:when>
                        <!-\- ENTITE 464 $t CONTIENT -\->
                        <xsl:when test="marc:subfield[@code = 't'][text() != '']">
                            <Entite>
                                <xsl:attribute name="id"
                                    select="concat($racineId, '/m/464/', position())"/>
                                <type lrm="MANIFESTATION">MANIFESTATION</type>
                                <xsl:call-template name="meta">
                                    <xsl:with-param name="citeDans" select="$PPN"/>
                                </xsl:call-template>
                                <relation xref="{concat($racineId,'/m/464/',position(),'/nomen')}">
                                    <type>A_POUR_NOMEN</type>
                                    <xsl:call-template name="meta"/>
                                </relation>
                            </Entite>
                            <Entite id="{concat($racineId,'/m/464/',position(),'/nomen')}">
                                <type lrm="NOMEN">NOMEN</type>
                                <type>TITRE</type>
                                <propriete nom="TYPE_ACCES">ng</propriete>
                                <propriete nom="VALEUR">
                                    <xsl:value-of select="normalize-space(.[1])"/>
                                </propriete>
                                <xsl:call-template name="meta">
                                    <xsl:with-param name="idSource" select="$PPN"/>
                                </xsl:call-template>
                            </Entite>
                        </xsl:when>
                    </xsl:choose>
                </xsl:for-each>
            </xsl:if>-->
            <!-- ENTITE liée par A_POUR_SUJET sans @code = '3'-->
            <xsl:for-each
                select="marc:datafield[@tag = '600' or @tag = '601' or @tag = '602' or @tag = '604' or @tag = '605' or @tag = '606' or @tag = '607' or @tag = '608'][not(marc:subfield[@code = '3'])][marc:subfield[@code = 'a']/text() != ''][$TR = 'false']">
                <xsl:variable name="referentiel">
                    <xsl:value-of select="normalize-space(lower-case(marc:subfield[@code = '2']))"/>
                </xsl:variable>
                <xsl:variable name="typeVedette">
                    <xsl:value-of select="@tag"/>
                </xsl:variable>
                <xsl:variable name="id">
                    <xsl:value-of select="concat($racineId, '/w/sujet/', position())"/>
                </xsl:variable>
                <Entite id="{$id}">
                    <xsl:call-template name="rameauVedette">
                        <xsl:with-param name="typeVedette" select="$typeVedette"/>
                    </xsl:call-template>
                    <xsl:if
                        test="$referentiel != '' and $typeVedette != '600' and $typeVedette != '601' and $typeVedette != '602'">
                        <propriete nom="REFERENTIEL">
                            <xsl:value-of select="$referentiel"/>
                        </propriete>
                    </xsl:if>
                    <xsl:call-template name="meta">
                        <xsl:with-param name="idSource" select="$PPN"/>
                    </xsl:call-template>
                    <relation xref="{concat($id,'/nomen')}">
                        <type>A_POUR_NOMEN</type>
                        <xsl:call-template name="meta"/>
                    </relation>
                </Entite>
                <Entite id="{concat($id,'/nomen')}">
                    <type lrm="NOMEN">NOMEN</type>
                    <xsl:call-template name="rameauNomen">
                        <xsl:with-param name="typeVedette" select="$typeVedette"/>
                    </xsl:call-template>
                    <propriete nom="TYPE_ACCES">ng</propriete>
                    <propriete nom="VALEUR">
                        <xsl:value-of select="normalize-space(marc:subfield[@code = 'a'])"/>
                    </propriete>
                    <propriete nom="ALPHABET">latin</propriete>
                    <propriete nom="LANGUE">français</propriete>
                    <xsl:call-template name="meta">
                        <xsl:with-param name="idSource" select="$PPN"/>
                    </xsl:call-template>
                </Entite>
            </xsl:for-each>
            <!-- ENTITE liée par A_POUR_SUJET_PRINCIPAL = vedette-->
            <xsl:for-each
                select="marc:datafield[@tag = '600' or @tag = '601' or @tag = '602' or @tag = '604' or @tag = '605' or @tag = '606' or @tag = '607' or @tag = '608']/marc:subfield[@code = '3'][position() = 1 and text() != ''][$TR = 'false']">
                <xsl:variable name="referentiel">
                    <xsl:value-of
                        select="normalize-space(lower-case(parent::marc:datafield/marc:subfield[@code = '2']))"
                    />
                </xsl:variable>
                <xsl:call-template name="rameau">
                    <xsl:with-param name="ppnRameau" select="text()"/>
                    <xsl:with-param name="referentiel" select="$referentiel"/>
                    <xsl:with-param name="mode" select="'entite'"/>
                    <xsl:with-param name="typeSub" select="'vedette'"/>
                    <xsl:with-param name="typeVedette" select="parent::marc:datafield/@tag"/>
                </xsl:call-template>
            </xsl:for-each>
            <!-- ENTITE liée par A_POUR_SPECIFICATION_SUJET/LIEU/TEMPS = subdivision-->
            <xsl:for-each
                select="marc:datafield[@tag = '600' or @tag = '601' or @tag = '602' or @tag = '604' or @tag = '605' or @tag = '606' or @tag = '607' or @tag = '608']/marc:subfield[@code = '3'][position() > 1 and text() != ''][$TR = 'false']">
                <xsl:variable name="referentiel">
                    <xsl:value-of
                        select="normalize-space(lower-case(parent::marc:datafield/marc:subfield[@code = '2']))"
                    />
                </xsl:variable>
                <xsl:call-template name="rameau">
                    <xsl:with-param name="referentiel" select="$referentiel"/>
                    <xsl:with-param name="ppnRameau" select="text()"/>
                    <xsl:with-param name="mode" select="'entite'"/>
                    <xsl:with-param name="typeSub" select="following-sibling::node()[1]/@code"/>
                </xsl:call-template>
            </xsl:for-each>
            <xsl:comment>---- Entite(s) Contributeur(s) niveau Oeuvre - Expression - Manifestation - Item----</xsl:comment>
            <xsl:variable name="rolesOeuvres">010 - 070 - 257 - 340 - 395 - 440 - 651</xsl:variable>
            <xsl:variable name="roles">010 - 070 - 080 - 257 - 280 - 320 - 340 - 390 - 395 - 440 -
                610 - 650 - 651 - 730</xsl:variable>
            <xsl:for-each
                select="marc:datafield[starts-with(@tag, '7')][marc:subfield[@code = '4'] and ($TR = 'false' or not(contains($rolesOeuvres, text())))][marc:subfield[@code = 'a']/text() != ''] | marc:datafield[@tag = '210' or @tag = '219' or @tag = '214']/marc:subfield[@code = 'c' and text() != '']">
                <xsl:variable name="typeEntite">
                    <xsl:choose>
                        <xsl:when test="@tag = '700' or @tag = '701' or @tag = '702'">
                            <xsl:text>PERSONNE</xsl:text>
                        </xsl:when>
                        <xsl:when test="@tag = '710' or @tag = '711' or @tag = '712' or not(@tag)">
                            <xsl:text>COLLECTIVITE</xsl:text>
                        </xsl:when>
                        <xsl:when test="@tag = '720' or @tag = '721' or @tag = '722'">
                            <xsl:text>FAMILLE</xsl:text>
                        </xsl:when>
                    </xsl:choose>
                </xsl:variable>
                <xsl:variable name="typeNomen">
                    <xsl:choose>
                        <xsl:when test="$typeEntite = 'PERSONNE'">
                            <xsl:text>PERSONNE</xsl:text>
                        </xsl:when>
                        <xsl:when test="$typeEntite = 'COLLECTIVITE'">
                            <xsl:text>COLLECTIVITE</xsl:text>
                        </xsl:when>
                        <xsl:when test="$typeEntite = 'FAMILLE'">
                            <xsl:text>FAMILLE</xsl:text>
                        </xsl:when>
                    </xsl:choose>
                </xsl:variable>
                <xsl:choose>
                    <xsl:when
                        test="marc:subfield[@code = '3'] and marc:subfield[@code = '4'][contains($roles, text())]">
                        <xsl:comment>  ---- Entite AGENT AUTORITE niveau Oeuvre - Expression - Item----</xsl:comment>
                        <xsl:variable name="idref"
                            select="concat('http://www.idref.fr/', marc:subfield[@code = '3'])"/>
                        <Entite>
                            <xsl:attribute name="id">
                                <xsl:value-of select="$idref"/>
                            </xsl:attribute>
                            <type lrm="AGENT">AGENT</type>
                            <type>
                                <xsl:value-of select="$typeEntite"/>
                            </type>
                            <xsl:call-template name="meta">
                                <xsl:with-param name="idSource" select="marc:subfield[@code = '3']"/>
                                <xsl:with-param name="citeDans" select="$PPN"/>
                            </xsl:call-template>
                            <relation xref="{concat($idref,'/nomen')}">
                                <type>A_POUR_NOMEN</type>
                                <xsl:call-template name="meta"/>
                            </relation>
                        </Entite>
                        <xsl:comment>---- Entite NOMEN AGENT AUTORITE niveau Oeuvre - Expression - Item----</xsl:comment>
                        <Entite id="{concat($idref,'/nomen')}">
                            <xsl:call-template name="nomen">
                                <xsl:with-param name="type" select="$typeNomen"/>
                                <xsl:with-param name="typeAcces" select="'paa'"/>
                            </xsl:call-template>
                            <xsl:call-template name="meta">
                                <xsl:with-param name="idSource" select="marc:subfield[@code = '3']"/>
                                <xsl:with-param name="citeDans" select="$PPN"/>
                            </xsl:call-template>
                        </Entite>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:variable name="id">
                            <xsl:choose>
                                <xsl:when
                                    test="marc:subfield[@code = 'a' and text() != ''] and marc:subfield[@code = '5'] and not(marc:subfield[@code = '3'])">
                                    <xsl:variable name="key5">
                                        <xsl:value-of select="marc:subfield[@code = '5']"/>
                                    </xsl:variable>
                                    <xsl:variable name="position"
                                        select="count(preceding-sibling::marc:datafield[starts-with(@tag, '7') and marc:subfield[@code = '5'] = $key5 and not(marc:subfield[@code = '3'])]) + 1"/>
                                    <xsl:value-of
                                        select="concat($racineId, '/i/', substring-after(marc:subfield[@code = '5'], ':'), '/contexte/', $position)"
                                    />
                                </xsl:when>
                                <xsl:otherwise>
                                    <!-- 19/02/20 ERM ajout de la condition [marc:subfield[@code = '4']] 
                                   <xsl:value-of
                                select="concat($racineId, '/m/contexte/', count(preceding-sibling::marc:datafield[starts-with(@tag, '7') or @tag = '210' or @tag = '219'][not(marc:subfield[@code = '5']) and not(marc:subfield[@code = '3'])]) + 1)"
                            />-->
                                    <!-- 21/02/20 ERM ça ne marche toujours pas !!-->
                                    <!-- 24/02/20 MJN ayé ça marche enfin !!-->
                                    <xsl:variable name="position"
                                        select="count(preceding-sibling::marc:datafield[starts-with(@tag, '7') and not(marc:subfield/@code = '5') and not(marc:subfield[@code = '3'])] | preceding-sibling::marc:datafield[(@tag = '210' or @tag = '219' or @tag = '214') and marc:subfield[@code = 'c'] != '']) + 1"/>
                                    <xsl:value-of
                                        select="concat($racineId, '/m/contexte/', $position)"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:variable>
                        <xsl:comment>---- Entite NOMEN MENTION CONTRIBUTION niveau Manifestion - Item---- </xsl:comment>
                        <Entite id="{$id}/contrib/nomen">
                            <xsl:call-template name="nomen">
                                <xsl:with-param name="type" select="$typeNomen"/>
                                <xsl:with-param name="typeAcces">
                                    <xsl:choose>
                                        <xsl:when test="not(marc:subfield[@code = '3'])"
                                            >ng</xsl:when>
                                        <xsl:otherwise>paa</xsl:otherwise>
                                    </xsl:choose>
                                </xsl:with-param>
                            </xsl:call-template>
                            <xsl:call-template name="meta">
                                <xsl:with-param name="idSource">
                                    <xsl:choose>
                                        <xsl:when test="not(marc:subfield[@code = '3'])">
                                            <xsl:value-of select="$PPN"/>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:value-of select="marc:subfield[@code = '3']"/>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:with-param>
                                <xsl:with-param name="citeDans">
                                    <xsl:choose>
                                        <xsl:when test="marc:subfield[@code = '3']">
                                            <xsl:value-of select="$PPN"/>
                                        </xsl:when>
                                    </xsl:choose>
                                </xsl:with-param>
                            </xsl:call-template>
                        </Entite>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
        </Wemi>
    </xsl:template>
    <xsl:template name="rameau">
        <xsl:param name="referentiel"/>
        <xsl:param name="ppnRameau"/>
        <xsl:param name="mode"/>
        <xsl:param name="typeSub"/>
        <xsl:param name="typeVedette"/>
        <xsl:variable name="xref">
            <xsl:value-of select="concat('http://www.idref.fr/', $ppnRameau)"/>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="$mode = 'relation'">
                <xsl:choose>
                    <xsl:when test="$typeSub = 'vedette'">
                        <relation xref="{$xref}">
                            <type>A_POUR_SUJET_PRINCIPAL</type>
                            <xsl:call-template name="meta"/>
                        </relation>
                    </xsl:when>
                    <xsl:otherwise>
                        <relation2 xref="{$xref}">
                            <xsl:choose>
                                <xsl:when test="$typeSub = 'x'">
                                    <type>A_POUR_SPECIFICATION_SUJET</type>
                                </xsl:when>
                                <xsl:when test="$typeSub = 'y'">
                                    <type>A_POUR_SPECIFICATION_LIEU</type>
                                </xsl:when>
                                <xsl:when test="$typeSub = 'z'">
                                    <type>A_POUR_SPECIFICATION_TEMPS</type>
                                </xsl:when>
                            </xsl:choose>
                            <xsl:call-template name="meta"/>
                        </relation2>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="$mode = 'entite'">
                <Entite id="{$xref}">
                    <xsl:choose>
                        <xsl:when test="$typeSub = 'vedette'">
                            <xsl:call-template name="rameauVedette">
                                <xsl:with-param name="typeVedette" select="$typeVedette"/>
                            </xsl:call-template>
                        </xsl:when>
                        <xsl:when test="$typeSub = 'x'">
                            <type lrm="CONCEPT">CONCEPT</type>
                        </xsl:when>
                        <xsl:when test="$typeSub = 'y'">
                            <type lrm="LIEU">LIEU</type>
                        </xsl:when>
                        <xsl:when test="$typeSub = 'z'">
                            <type lrm="TEMPS">TEMPS</type>
                        </xsl:when>
                    </xsl:choose>
                    <propriete nom="REFERENTIEL">
                        <xsl:value-of select="$referentiel"/>
                    </propriete>
                    <xsl:call-template name="meta">
                        <xsl:with-param name="idSource" select="$ppnRameau"/>
                    </xsl:call-template>
                    <relation xref="{concat($xref ,'/nomen')}">
                        <type>A_POUR_NOMEN</type>
                        <xsl:call-template name="meta"/>
                    </relation>
                </Entite>
                <Entite id="{concat($xref ,'/nomen')}">
                    <type lrm="NOMEN">NOMEN</type>
                    <xsl:choose>
                        <xsl:when test="$typeSub = 'vedette'">
                            <xsl:call-template name="rameauNomen">
                                <xsl:with-param name="typeVedette" select="$typeVedette"/>
                            </xsl:call-template>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:choose>
                                <xsl:when test="$typeSub = 'x'">
                                    <type>NOM_COMMUN</type>
                                </xsl:when>
                                <xsl:when test="$typeSub = 'y'">
                                    <type>NOM_LIEU</type>
                                </xsl:when>
                                <xsl:when test="$typeSub = 'z'">
                                    <type>NOM_TEMPS</type>
                                </xsl:when>
                            </xsl:choose>
                        </xsl:otherwise>
                    </xsl:choose>
                    <propriete nom="TYPE_ACCES">paa</propriete>
                    <xsl:choose>
                        <xsl:when test="$typeSub = 'vedette'">
                            <propriete nom="VALEUR">
                                <xsl:value-of select="following-sibling::node()[@code = 'a'][1]"/>
                                <xsl:if test="following-sibling::node()[@code = 'b'][1]">
                                    <xsl:value-of
                                        select="concat(',&#x20;', following-sibling::node()[@code = 'b'][1])"
                                    />
                                </xsl:if>
                            </propriete>
                            <xsl:if test="$typeVedette = '600'">
                                <propriete nom="NOM">
                                    <xsl:value-of select="following-sibling::node()[@code = 'a'][1]"
                                    />
                                </propriete>
                                <xsl:if test="following-sibling::node()[@code = 'b'][1] != ''">
                                    <propriete nom="PRENOM">
                                        <xsl:value-of
                                            select="following-sibling::node()[@code = 'b'][1]"/>
                                    </propriete>
                                </xsl:if>
                            </xsl:if>
                        </xsl:when>
                        <xsl:otherwise>
                            <propriete nom="VALEUR">
                                <xsl:value-of select="following-sibling::node()[1]"/>
                            </propriete>
                        </xsl:otherwise>
                    </xsl:choose>
                    <propriete nom="ALPHABET">latin</propriete>
                    <propriete nom="LANGUE">français</propriete>
                    <xsl:call-template name="meta">
                        <xsl:with-param name="idSource" select="$ppnRameau"/>
                    </xsl:call-template>
                </Entite>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    <!--*********************************************************************************
                                                                  ERM le 15/01/20    DEBUT                                                          
                  *****************************************************************************-->
    <xsl:template name="manifCompte">
        <xsl:param name="type"/>
        <xsl:param name="typePub"/>
        <xsl:param name="typePubSerie"/>
        <xsl:param name="PPN"/>
        <xsl:param name="racineId"/>
        <xsl:choose>
            <xsl:when
                test="$type = 'Electronique' and marc:datafield[@tag = '856'][not(marc:subfield[@code = '5'])][marc:subfield[@code = 'u']]">
                <xsl:comment>--- Elec via 856 ---</xsl:comment>
                <xsl:variable name="manif" as="xs:string*">
                    <xsl:for-each-group
                        select="marc:datafield[@tag = '856'][not(marc:subfield[@code = '5'])]"
                        group-by="marc:subfield[@code = 'u']">
                        <xsl:choose>
                            <xsl:when test="current-group()[marc:subfield[@code = 'q']]">
                                <xsl:for-each-group select="current-group()"
                                    group-by="marc:subfield[@code = 'q']">
                                    <xsl:sequence select="current-grouping-key()"/>
                                    <!--    <xsl:comment> 
                                                uri avec format dédoublonnés : 
                                                <xsl:sequence select="current-grouping-key()"/>
                                            </xsl:comment>-->
                                </xsl:for-each-group>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:sequence select="current-grouping-key()"/>
                                <!-- <xsl:comment> 
                                            uri sans format dédoublonnés : 
                                            <xsl:sequence select="current-grouping-key()"/>
                                        </xsl:comment>-->
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:for-each-group>
                </xsl:variable>
                <!-- <xsl:comment>
                            les manifs :
                              <xsl:value-of select="$manif"/>
                            nb de manif :                             
                      </xsl:comment>-->
                <xsl:value-of select="count($manif)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:comment>
                    <xsl:choose>
                            <xsl:when test="$type = 'Electronique'">--- Elec via 010 ---</xsl:when>
                            <xsl:otherwise>--- Imprime et autres via 010 ---</xsl:otherwise>
                       </xsl:choose>
                </xsl:comment>
                <xsl:variable name="manif" as="xs:string*">
                    <xsl:variable name="manif_isbn" as="xs:string*">
                        <xsl:for-each-group
                            select="marc:datafield[@tag = '010'][marc:subfield[@code = 'a']]"
                            group-by="marc:subfield[@code = 'a']">
                            <xsl:choose>
                                <xsl:when test="current-group()[marc:subfield[@code = 'b']]">
                                    <xsl:for-each-group select="current-group()"
                                        group-by="marc:subfield[@code = 'b']">
                                        <xsl:sequence select="current-grouping-key()"/>
                                        <!-- <xsl:comment> 
                                                isbn avec format dédoublonnés : 
                                                <xsl:sequence select="current-grouping-key()"/>
                                            </xsl:comment>-->
                                    </xsl:for-each-group>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:sequence select="current-grouping-key()"/>
                                    <!-- <xsl:comment> 
                                            isbn sans format dédoublonnés : 
                                            <xsl:sequence select="current-grouping-key()"/>
                                        </xsl:comment>-->
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:for-each-group>
                    </xsl:variable>
                    <!--   <xsl:comment>
                            les manifs avec isbn :
                              <xsl:value-of select="$manif_isbn"/>
                            nb de manif avec isbn :    <xsl:value-of select="count($manif_isbn)"/>
                      </xsl:comment>-->
                    <xsl:choose>
                        <xsl:when test="$type = 'Electronique'">
                            <xsl:value-of select="count($manif_isbn)"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:choose>
                                <xsl:when
                                    test="marc:datafield[@tag = '010'][not(marc:subfield[@code = 'a'])][contains(lower-case(marc:subfield[@code = 'b'][1]), 'br')] and marc:datafield[@tag = '010'][not(marc:subfield[@code = 'a'])][contains(lower-case(marc:subfield[@code = 'b'][1]), 'rel')]">
                                    <xsl:value-of select="count($manif_isbn) + 2"/>
                                </xsl:when>
                                <xsl:when
                                    test="marc:datafield[@tag = '010'][not(marc:subfield[@code = 'a'])][contains(lower-case(marc:subfield[@code = 'b'][1]), 'br')] or marc:datafield[@tag = '010'][not(marc:subfield[@code = 'a'])][contains(lower-case(marc:subfield[@code = 'b'][1]), 'rel')]">
                                    <xsl:value-of select="count($manif_isbn) + 1"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="count($manif_isbn)"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:variable name="nb_manif">
                    <xsl:choose>
                        <xsl:when test="number($manif) = 0">1</xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="$manif"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:value-of select="$nb_manif"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template name="manifBoucle">
        <xsl:param name="type"/>
        <xsl:param name="typePub"/>
        <xsl:param name="typePubSerie"/>
        <xsl:param name="PPN"/>
        <xsl:param name="racineId"/>
        <xsl:param name="mode"/>
        <xsl:param name="fin"/>
        <xsl:param name="nbManif"/>
        <xsl:param name="compteur"/>
        <xsl:param name="typeManif"/>
        <xsl:call-template name="manifAppel">
            <xsl:with-param name="type" select="$type"/>
            <xsl:with-param name="typePub" select="$typePub"/>
            <xsl:with-param name="typePubSerie" select="$typePubSerie"/>
            <xsl:with-param name="PPN" select="$PPN"/>
            <xsl:with-param name="racineId" select="$racineId"/>
            <xsl:with-param name="mode" select="$mode"/>
            <xsl:with-param name="fin" select="$fin"/>
            <xsl:with-param name="nbManif" select="$nbManif"/>
            <xsl:with-param name="compteur" select="$compteur"/>
            <xsl:with-param name="typeManif" select="$typeManif"/>
        </xsl:call-template>
        <xsl:choose>
            <xsl:when test="number($fin) = 1"/>
            <xsl:when test="number($compteur) &lt; number($fin)">
                <xsl:call-template name="manifBoucle">
                    <xsl:with-param name="type" select="$type"/>
                    <xsl:with-param name="typePub" select="$typePub"/>
                    <xsl:with-param name="typePubSerie" select="$typePubSerie"/>
                    <xsl:with-param name="PPN" select="$PPN"/>
                    <xsl:with-param name="racineId" select="$racineId"/>
                    <xsl:with-param name="mode" select="$mode"/>
                    <xsl:with-param name="fin" select="$fin"/>
                    <xsl:with-param name="compteur" select="$compteur + 1"/>
                    <xsl:with-param name="typeManif" select="$typeManif"/>
                    <xsl:with-param name="nbManif" select="$nbManif"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="number($compteur) = number($fin)">
                <xsl:call-template name="manifBoucle">
                    <xsl:with-param name="type" select="$type"/>
                    <xsl:with-param name="typePub" select="$typePub"/>
                    <xsl:with-param name="typePubSerie" select="$typePubSerie"/>
                    <xsl:with-param name="PPN" select="$PPN"/>
                    <xsl:with-param name="racineId" select="$racineId"/>
                    <xsl:with-param name="mode" select="$mode"/>
                    <xsl:with-param name="fin" select="$fin"/>
                    <xsl:with-param name="compteur" select="$compteur + 1"/>
                    <xsl:with-param name="typeManif" select="'manifExemplaires'"/>
                    <xsl:with-param name="nbManif" select="$nbManif"/>
                </xsl:call-template>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    <xsl:template name="manifAppel">
        <xsl:param name="type"/>
        <xsl:param name="typePub"/>
        <xsl:param name="typePubSerie"/>
        <xsl:param name="PPN"/>
        <xsl:param name="racineId"/>
        <xsl:param name="mode"/>
        <xsl:param name="fin"/>
        <xsl:param name="nbManif"/>
        <xsl:param name="compteur"/>
        <xsl:param name="typeManif"/>
        <xsl:variable name="numManif">
            <xsl:choose>
                <xsl:when test="number($compteur) > number($fin)">
                    <xsl:text>manifNotice</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="number($compteur)"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="$mode = 'relation'">
                <relation>
                    <xsl:attribute name="xref" select="concat($racineId, '/m_', $numManif)"/>
                    <type>A_POUR_MANIFESTATION</type>
                    <xsl:call-template name="meta"/>
                </relation>
            </xsl:when>
            <xsl:when test="$mode = 'entite'">
                <Entite>
                    <xsl:attribute name="id" select="concat($racineId, '/m_', $numManif)"/>
                    <!-- gestion des propriété communes -->
                    <xsl:call-template name="manifEntitePropriete">
                        <xsl:with-param name="type" select="$type"/>
                        <xsl:with-param name="typePub" select="$typePub"/>
                        <xsl:with-param name="typePubSerie" select="$typePubSerie"/>
                        <xsl:with-param name="PPN" select="$PPN"/>
                        <xsl:with-param name="numManif" select="$numManif"/>
                        <xsl:with-param name="racineId" select="$racineId"/>
                        <xsl:with-param name="typeManif" select="$typeManif"/>                        
                        <xsl:with-param name="nbManif" select="$nbManif"/>
                    </xsl:call-template>
                    <!-- gestion des propriété spécifiques -->
                    <xsl:call-template name="manifSpec">
                        <xsl:with-param name="type" select="$type"/>
                        <xsl:with-param name="typePub" select="$typePub"/>
                        <xsl:with-param name="typePubSerie" select="$typePubSerie"/>
                        <xsl:with-param name="PPN" select="$PPN"/>
                        <xsl:with-param name="numManif" select="$numManif"/>
                        <xsl:with-param name="typeManif" select="$typeManif"/>
                        <xsl:with-param name="nbManif" select="$nbManif"/>
                    </xsl:call-template>
                    <!-- gestion des relations -->
                    <xsl:call-template name="manifEntiteRelation">
                        <xsl:with-param name="type" select="$type"/>
                        <xsl:with-param name="typePub" select="$typePub"/>
                        <xsl:with-param name="typePubSerie" select="$typePubSerie"/>
                        <xsl:with-param name="PPN" select="$PPN"/>
                        <xsl:with-param name="racineId" select="$racineId"/>
                        <xsl:with-param name="typeManif" select="$typeManif"/>
                        <!--<xsl:with-param name="numManif" select="$numManif"/>-->
                        <!-- <xsl:with-param name="idManif" select="concat($racineId, '/m/', $numManif)"/>-->
                    </xsl:call-template>
                </Entite>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    <xsl:template name="manifEntitePropriete">
        <xsl:param name="type"/>
        <xsl:param name="typePub"/>
        <xsl:param name="typePubSerie"/>
        <xsl:param name="racineId"/>
        <xsl:param name="PPN"/>
        <xsl:param name="typeManif"/>
        <xsl:param name="numManif"/>
        <xsl:param name="nbManif"/>
        <!--<xsl:comment> typeManif : <xsl:value-of select="$typeManif"/>-->
        <!--</xsl:comment>-->
        <xsl:choose>
            <xsl:when test="$typePub = 'MONOGRAPHIE'">
                <type lrm="MANIFESTATION">MANIFESTATION</type>
            </xsl:when>
            <xsl:otherwise>
                <type lrm="MANIFESTATION_AGREGATIVE">MANIFESTATION_AGREGATIVE</type>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:if test="$type != ''">
            <type>
                <xsl:value-of select="$type"/>
            </type>
        </xsl:if>
        <xsl:if test="$typePub != ''">
            <type>
                <xsl:value-of select="$typePub"/>
            </type>
        </xsl:if>
        <xsl:if test="$typePubSerie != ''">
            <type>
                <xsl:value-of select="$typePubSerie"/>
            </type>
        </xsl:if>
        <xsl:comment>---propriétés niveau Manifestation ----</xsl:comment>
        <xsl:call-template name="meta">
            <xsl:with-param name="idSource" select="$PPN"/>
        </xsl:call-template>
        <!-- propriete numManif-->
        <propriete nom="NUM_MANIF">
            <!--<xsl:value-of select="concat($PPN, '_', $numManif)"/>  on réutilise cette propriété pour préciser si c'est une manifestation avec ou sans exemplaire + le nb de manifestations si plusieurs-->
            <xsl:value-of select="concat($typeManif,' - ',$nbManif,' manif(s)')"/>
        </propriete>
        <!--propriete identifiants issn -->
        <xsl:for-each select="marc:datafield[@tag = '011']/marc:subfield[@code = 'a']">
            <propriete nom="ISSN">
                <xsl:value-of select="normalize-space(.)"/>
            </propriete>
        </xsl:for-each>
        <!--        <!-\- propriete titrePropre-\->
        <xsl:if
            test="marc:datafield[@tag = '200']/marc:subfield[@code = 'a'] != ''">
            <propriete nom="TITRE_PROPRE">
                <xsl:value-of
                    select="marc:datafield[@tag = '200']/marc:subfield[@code = 'a']"
                />
            </propriete>
        </xsl:if>-->
        <!-- propriete mentionEdition-->
        <xsl:for-each
            select="marc:datafield[@tag = '205']/marc:subfield[@code = 'a' and text() != '']">
            <propriete nom="MENTION_EDITION">
                <xsl:value-of select="."/>
            </propriete>
        </xsl:for-each>
        <!--propriete date -->
        <xsl:choose>
            <xsl:when
                test="substring(marc:datafield[@tag = '100']/marc:subfield[@code = 'a'], 9, 1) = 'd' or substring(parent::marc:record/marc:datafield[@tag = '100']/marc:subfield[@code = 'a'], 9, 1) = 'e' or substring(parent::marc:record/marc:datafield[@tag = '100']/marc:subfield[@code = 'a'], 9, 1) = 'f' or substring(parent::marc:record/marc:datafield[@tag = '100']/marc:subfield[@code = 'a'], 9, 1) = 'h' or substring(parent::marc:record/marc:datafield[@tag = '100']/marc:subfield[@code = 'a'], 9, 1) = 'i' or substring(parent::marc:record/marc:datafield[@tag = '100']/marc:subfield[@code = 'a'], 9, 1) = 'j' or substring(parent::marc:record/marc:datafield[@tag = '100']/marc:subfield[@code = 'a'], 9, 1) = 'k'">
                <xsl:variable name="annee"
                    select="string(number(substring(marc:datafield[@tag = '100']/marc:subfield[@code = 'a'], 10, 4)))"/>
                <xsl:if test="string-length($annee) = 4">
                    <propriete nom="ANNEE_PUBLICATION">
                        <xsl:value-of select="$annee"/>
                    </propriete>
                </xsl:if>
            </xsl:when>
            <xsl:when
                test="substring(marc:datafield[@tag = '100']/marc:subfield[@code = 'a'], 9, 1) = 'a' or substring(parent::marc:record/marc:datafield[@tag = '100']/marc:subfield[@code = 'a'], 9, 1) = 'b' or substring(parent::marc:record/marc:datafield[@tag = '100']/marc:subfield[@code = 'a'], 9, 1) = 'c' or substring(parent::marc:record/marc:datafield[@tag = '100']/marc:subfield[@code = 'a'], 9, 1) = 'g'">
                <xsl:variable name="annee_debut"
                    select="string(number(substring(marc:datafield[@tag = '100']/marc:subfield[@code = 'a'], 10, 4)))"/>
                <xsl:if test="string-length($annee_debut) = 4">
                    <propriete nom="ANNEE_PUBLICATION_DEBUT">
                        <xsl:value-of select="$annee_debut"/>
                    </propriete>
                </xsl:if>
                <xsl:variable name="annee_fin"
                    select="string(number(substring(marc:datafield[@tag = '100']/marc:subfield[@code = 'a'], 14, 4)))"/>
                <xsl:if test="string-length($annee_fin) = 4 and $annee_fin != '9999'">
                    <propriete nom="ANNEE_PUBLICATION_FIN">
                        <xsl:value-of
                            select="substring(marc:datafield[@tag = '100']/marc:subfield[@code = 'a'], 14, 4)"
                        />
                    </propriete>
                </xsl:if>
            </xsl:when>
        </xsl:choose>
        <!--propriete periodicite -->
        <xsl:if
            test="substring(marc:datafield[@tag = '110']/marc:subfield[@code = 'a'], 2, 1) != ''">
            <propriete nom="PERIODICITE">
                <xsl:call-template name="perio">
                    <xsl:with-param name="code">
                        <xsl:value-of
                            select="substring(marc:datafield[@tag = '110']/marc:subfield[@code = 'a'], 2, 1)"
                        />
                    </xsl:with-param>
                </xsl:call-template>
            </propriete>
        </xsl:if>
        <!--propriete note -->
        <xsl:for-each select="marc:datafield[@tag = '320']/marc:subfield[@code = 'a']">
            <propriete nom="NOTES">
                <xsl:value-of select="normalize-space(.)"/>
            </propriete>
        </xsl:for-each>
    </xsl:template>
    <xsl:template name="manifEntiteRelation">
        <xsl:param name="type"/>
        <xsl:param name="typePub"/>
        <xsl:param name="typePubSerie"/>
        <xsl:param name="racineId"/>
        <xsl:param name="PPN"/>
        <xsl:param name="typeManif"/>
        <!-- <xsl:param name="numManif"/>-->
        <!--<xsl:param name="idManif"/>-->
        <xsl:comment>---relations niveau Manifestation ----</xsl:comment>
        <!-- relation titrePropre-->
        <xsl:for-each
            select="marc:datafield[@tag = '200']/marc:subfield[@code = 'a' and text() != '']">
            <relation>
                <xsl:attribute name="xref" select="concat($racineId, '/m/nomen/', position())"/>
                <type>A_POUR_NOMEN</type>
                <xsl:call-template name="meta"/>
            </relation>
        </xsl:for-each>
        <!--RELATION Contributeurs (niveau manifestation)-->
        <!-- RELATION2 pour mention contributeur niveau Manif-->
        <xsl:variable name="roles">080 - 440 - 650</xsl:variable>
        <xsl:for-each
            select="marc:datafield[starts-with(@tag, '7') and not(marc:subfield/@code = '5') and marc:subfield[@code = 'a' and text() != '']] | marc:datafield[@tag = '210' or @tag = '219' or @tag = '214']/marc:subfield[@code = 'c' and text() != '']">
            <xsl:comment>---- contributeur / mention  niveau Manif ----</xsl:comment>
            <!--<xsl:variable name="codefct"> <!-\- code fonction en $4 sauf pour l'éditeur commercial récupéré dans la 210 ou 214 : dans ce cas 650 -\->
                <xsl:choose>
                    <xsl:when test="self::node()[starts-with(@tag, '7')]">
                        <xsl:value-of select="marc:subfield[@code = '4']"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>650</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>-->
            <xsl:choose>
                <xsl:when
                    test="marc:subfield[@code = '3'] and (@tag = '702' or @tag = '712' or @tag = '722') and marc:subfield[@code = '4'][contains($roles, text())]">
                    <!-- relation contributeur : si $3 ET si 702, 712 ou 722 ET codes fct dans variable roles-->
                    <xsl:comment>---relation contributeur niveau Manif ----</xsl:comment>
                    <xsl:call-template name="contrib_relation">
                        <xsl:with-param name="PPN" select="$PPN"/>
                        <xsl:with-param name="mode" select="'relation_agent'"/>
                        <!--<xsl:with-param name="codefct" select="$codefct"/>-->
                    </xsl:call-template>
                </xsl:when>
                <xsl:when test="not(marc:subfield[@code = '3'])">
                    <xsl:variable name="position"
                        select="count(preceding-sibling::marc:datafield[starts-with(@tag, '7') and not(marc:subfield/@code = '5') and not(marc:subfield[@code = '3']) and marc:subfield[@code = 'a' and text() != '']] | preceding-sibling::marc:datafield[@tag = '210' or @tag = '219' or @tag = '214']/marc:subfield[@code = 'c' and text() != '']) + 1"/>
                    <xsl:variable name="idMention"
                        select="concat($racineId, '/m/contexte/', $position)"/>
                    <xsl:comment>---- mention contributeur niveau Manif ---- position : <xsl:value-of select="$position"/></xsl:comment>
                    <xsl:call-template name="contrib_relation">
                        <xsl:with-param name="mode" select="'relation_mention'"/>
                        <xsl:with-param name="PPN" select="$PPN"/>
                        <!--  <xsl:with-param name="numManif" select="$numManif"/>
                        <xsl:with-param name="idManif" select="$idManif"/>-->
                        <xsl:with-param name="idMention" select="$idMention"/>
                        <xsl:with-param name="position" select="$position"/>
                        <!--<xsl:with-param name="codefct" select="$codefct"/>-->
                    </xsl:call-template>
                </xsl:when>
                <xsl:otherwise/>
            </xsl:choose>
        </xsl:for-each>
        <!-- RELATION CONTRIB COMMENTEE PAR ERM  -->
        <!--</xsl:for-each>
            <xsl:for-each
            select="marc:datafield[starts-with(@tag, '7')][marc:subfield[not(@code = '5')]] | parent::marc:record/marc:datafield[@tag = '210' or @tag = '219']/marc:subfield[@code = 'c']">
            <xsl:variable name="idMention" select="concat($idManif, '/contexte/', position())"/>
            <xsl:if
                test="self::marc:datafield[starts-with(@tag, '7')][not(marc:subfield[@code = '3'])] | marc:datafield[@tag = '210' or @tag = '219']/marc:subfield[@code = 'c']">
                               <relation>
                    <type>A_POUR_MENTION</type>
                    <xsl:call-template name="meta"/>
                    <Entite id="{$idMention}">
                          <type lrm="CONTEXTE">CONTEXTE</type>
                                            <type>CONTRIBUTION</type>
                        <xsl:call-template name="meta">
                            <xsl:with-param name="idSource" select="$PPN"/>
                        </xsl:call-template>
                        <xsl:choose>
                            <xsl:when test="marc:subfield[@code = '4'] != ''">
                                <xsl:call-template name="role">
                                    <xsl:with-param name="codefct"
                                        select="marc:subfield[@code = '4']"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="self::node()[starts-with(@tag, '7')]">
                                <propriete nom="ROLE">Contributeur</propriete>
                            </xsl:when>
                            <xsl:otherwise>
                                <propriete nom="ROLE">Editeur commercial</propriete>
                            </xsl:otherwise>
                        </xsl:choose>
                        <relation xref="{$idMention}/contrib/nomen">
                            <type>A_POUR_MENTION_DE_CONTRIBUTEUR</type>
                            <xsl:call-template name="meta"/>
                        </relation>
                    </Entite>
                </relation>
            </xsl:if>
        </xsl:for-each>-->
        <!-- RELATION Titre clé -->
        <xsl:for-each select="marc:datafield[@tag = '530'][marc:subfield[@code = 'a'] != '']">
            <relation>
                <xsl:attribute name="xref" select="concat($racineId, '/m/nomen/cle')"/>
                <type>A_POUR_NOMEN</type>
                <xsl:call-template name="meta"/>
            </relation>
        </xsl:for-each>
        <xsl:comment>----relation(s) via 4XX  ----</xsl:comment>
        <!-- RELATION à d'autre(s) arbre(s) WEMI-->
        <!-- RELATION 451 A_POUR_AUTRE_EDITION_MEME_SUPPORT-->
        <xsl:for-each select="marc:datafield[(@tag = '451')]">
            <xsl:choose>
                <xsl:when test="marc:subfield[@code = '0']">
                    <relation>
                        <xsl:attribute name="xref"
                            select="concat('http://www.abes.fr/', marc:subfield[@code = '0'], '/m')"/>
                        <type>A_POUR_AUTRE_EDITION_MEME_SUPPORT</type>
                        <xsl:call-template name="meta"/>
                        <bidon> <!-- propriétés pour xsl "bidon" pour chargement dans Oracle -->
                            <lien>451</lien>
                            <xsl:call-template name="zones4XX">
                                            <xsl:with-param name="typePub" select="$typePub" />
                                        </xsl:call-template>
                            <xsl:call-template name="meta">
                                <xsl:with-param name="idSource" select="marc:subfield[@code= '0']"/>
                                <xsl:with-param name="citeDans" select="$PPN"/>
                            </xsl:call-template>
                        </bidon>
                    </relation>
                </xsl:when>
                <xsl:when test="marc:subfield[@code = 't']">
                    <relation>
                        <xsl:attribute name="xref" select="concat($racineId, '/m/451/',position())"/>
                        <type>A_POUR_AUTRE_EDITION_MEME_SUPPORT</type>
                        <xsl:call-template name="meta"/>
                        <bidon> <!-- propriétés pour xsl "bidon" pour chargement dans Oracle -->
                            <lien>451</lien>
                            <xsl:call-template name="zones4XX">
                                            <xsl:with-param name="typePub" select="$typePub" />
                                        </xsl:call-template>
                            <xsl:call-template name="meta">
                                <xsl:with-param name="citeDans" select="$PPN"/>
                            </xsl:call-template>
                        </bidon>
                    </relation>
                </xsl:when>
            </xsl:choose>
        </xsl:for-each>
        <!-- RELATION 452 A_POUR_AUTRE_EDITION_SUPPORT_DIFFERENT-->
        <xsl:for-each select="marc:datafield[(@tag = '452')]">
            <xsl:choose>
                <xsl:when test="marc:subfield[@code = '0']">
                    <relation>
                        <xsl:attribute name="xref"
                            select="concat('http://www.abes.fr/', marc:subfield[@code = '0'], '/m')"/>
                        <type>A_POUR_AUTRE_EDITION_SUPPORT_DIFFERENT</type>
                        <xsl:call-template name="meta"/>
                        <bidon> <!-- propriétés pour xsl "bidon" pour chargement dans Oracle -->
                            <lien>452</lien>
                            <xsl:call-template name="zones4XX">
                                            <xsl:with-param name="typePub" select="$typePub" />
                                        </xsl:call-template>
                            <xsl:call-template name="meta">
                                <xsl:with-param name="idSource" select="marc:subfield[@code= '0']"/>
                                <xsl:with-param name="citeDans" select="$PPN"/>
                            </xsl:call-template>
                        </bidon>
                    </relation>
                </xsl:when>
                <xsl:when test="marc:subfield[@code = 't']">
                    <relation>
                        <xsl:attribute name="xref" select="concat($racineId, '/m/452/',position())"/>
                        <type>A_POUR_AUTRE_EDITION_SUPPORT_DIFFERENT</type>
                        <xsl:call-template name="meta"/>
                        <bidon> <!-- propriétés pour xsl "bidon" pour chargement dans Oracle -->
                            <lien>452</lien>
                            <xsl:call-template name="zones4XX">
                                            <xsl:with-param name="typePub" select="$typePub" />
                                        </xsl:call-template>
                            <xsl:call-template name="meta">
                                <xsl:with-param name="citeDans" select="$PPN"/>
                            </xsl:call-template>
                        </bidon>
                    </relation>
                </xsl:when>
            </xsl:choose>
        </xsl:for-each>
        <!-- RELATION 455 EST_UNE_REPRODUCTION_DE-->
        <xsl:for-each select="marc:datafield[(@tag = '455')]">
            <xsl:choose>
                <xsl:when test="marc:subfield[@code = '0']">
                    <relation>
                        <xsl:attribute name="xref"
                            select="concat('http://www.abes.fr/', marc:subfield[@code = '0'], '/m')"/>
                        <type>EST_UNE_REPRODUCTION_DE</type>
                        <xsl:call-template name="meta"/>
                        <bidon> <!-- propriétés pour xsl "bidon" pour chargement dans Oracle -->
                            <lien>455</lien>
                            <xsl:call-template name="zones4XX">
                                            <xsl:with-param name="typePub" select="$typePub" />
                                        </xsl:call-template>
                            <xsl:call-template name="meta">
                                <xsl:with-param name="idSource" select="marc:subfield[@code= '0']"/>
                                <xsl:with-param name="citeDans" select="$PPN"/>
                            </xsl:call-template>
                        </bidon>
                    </relation>
                </xsl:when>
                <xsl:when test="marc:subfield[@code = 't']">
                    <relation>
                        <xsl:attribute name="xref" select="concat($racineId, '/m/455/', position())"/>
                        <type>EST_UNE_REPRODUCTION_DE</type>
                        <xsl:call-template name="meta"/>
                        <bidon> <!-- propriétés pour xsl "bidon" pour chargement dans Oracle -->
                            <lien>455</lien>
                            <xsl:call-template name="zones4XX">
                                            <xsl:with-param name="typePub" select="$typePub" />
                                        </xsl:call-template>
                            <xsl:call-template name="meta">
                                <xsl:with-param name="citeDans" select="$PPN"/>
                            </xsl:call-template>
                        </bidon>
                    </relation>
                </xsl:when>
            </xsl:choose>
        </xsl:for-each>
        <!-- RELATION 410 EST_AGREGE_DANS-->
        <xsl:for-each select="marc:datafield[(@tag = '410')]">
            <xsl:choose>
                <xsl:when test="marc:subfield[@code = '0']">
                    <relation>
                        <xsl:attribute name="xref"
                            select="concat('http://www.abes.fr/', marc:subfield[@code = '0'], '/m')"/>
                        <type>EST_AGREGE_DANS</type>
                        <xsl:call-template name="meta"/>
                        <xsl:for-each select="marc:subfield[@code = 'v' and text() != '']">
                            <propriete nom="NUM_VOL">
                                <xsl:value-of select="."/>
                            </propriete>
                        </xsl:for-each>
                        <bidon> <!-- propriétés pour xsl "bidon" pour chargement dans Oracle -->
                            <lien>410</lien>
                            <xsl:call-template name="zones4XX">
                                            <xsl:with-param name="typePub" select="$typePub" />
                                        </xsl:call-template>
                            <xsl:call-template name="meta">
                                <xsl:with-param name="idSource" select="marc:subfield[@code= '0']"/>
                                <xsl:with-param name="citeDans" select="$PPN"/>
                            </xsl:call-template>
                        </bidon>
                    </relation>
                </xsl:when>
                <xsl:when test="marc:subfield[@code = 't']">
                    <relation>
                        <xsl:attribute name="xref" select="concat($racineId, '/m/410/',position())"/>
                        <type>EST_AGREGE_DANS</type>
                        <xsl:call-template name="meta"/>
                        <xsl:for-each select="marc:subfield[@code = 'v' and text() != '']">
                            <propriete nom="NUM_VOL">
                                <xsl:value-of select="."/>
                            </propriete>
                        </xsl:for-each>
                        <bidon> <!-- propriétés pour xsl "bidon" pour chargement dans Oracle -->
                            <lien>410</lien>
                            <xsl:call-template name="zones4XX">
                                            <xsl:with-param name="typePub" select="$typePub" />
                                        </xsl:call-template>
                            <xsl:call-template name="meta">
                                <xsl:with-param name="citeDans" select="$PPN"/>
                            </xsl:call-template>
                        </bidon>
                    </relation>
                </xsl:when>
            </xsl:choose>
        </xsl:for-each>
        <!-- RELATION 461  EST_AGREGE_DANS -->
        <xsl:for-each select="marc:datafield[(@tag = '461')]">
            <xsl:choose>
                <xsl:when test="marc:subfield[@code = '0']">
                    <relation>
                        <xsl:attribute name="xref"
                            select="concat('http://www.abes.fr/', marc:subfield[@code = '0'], '/m')"/>
                        <type>EST_AGREGE_DANS</type>
                        <xsl:call-template name="meta"/>
                        <xsl:for-each select="marc:subfield[@code = 'v' and text() != '']">
                            <propriete nom="NUM_VOL">
                                <xsl:value-of select="."/>
                            </propriete>
                        </xsl:for-each>
                        <bidon> <!-- propriétés pour xsl "bidon" pour chargement dans Oracle -->
                            <lien>461</lien>
                            <xsl:call-template name="zones4XX">
                                            <xsl:with-param name="typePub" select="$typePub" />
                                        </xsl:call-template>
                            <xsl:call-template name="meta">
                                <xsl:with-param name="idSource" select="marc:subfield[@code= '0']"/>
                                <xsl:with-param name="citeDans" select="$PPN"/>
                            </xsl:call-template>
                        </bidon>
                    </relation>
                </xsl:when>
                <xsl:when test="marc:subfield[@code = 't']">
                    <relation>
                        <xsl:attribute name="xref" select="concat($racineId, '/m/461/',position())"/>
                        <type>EST_AGREGE_DANS</type>
                        <xsl:call-template name="meta"/>
                        <xsl:for-each select="marc:subfield[@code = 'v' and text() != '']">
                            <propriete nom="NUM_VOL">
                                <xsl:value-of select="."/>
                            </propriete>
                        </xsl:for-each>
                        <bidon> <!-- propriétés pour xsl "bidon" pour chargement dans Oracle -->
                            <lien>461</lien>
                            <xsl:call-template name="zones4XX">
                                            <xsl:with-param name="typePub" select="$typePub" />
                                        </xsl:call-template>
                            <xsl:call-template name="meta">
                                <xsl:with-param name="citeDans" select="$PPN"/>
                            </xsl:call-template>
                        </bidon>
                    </relation>
                </xsl:when>
            </xsl:choose>
        </xsl:for-each>
        <!-- RELATION 464 AGREGE (OEUVRE)-->
        <xsl:for-each select="marc:datafield[@tag = '464']">
            <xsl:choose>
                <xsl:when test="marc:subfield[@code = '0']">
                    <relation>
                        <xsl:attribute name="xref"
                            select="concat('http://www.abes.fr/', marc:subfield[@code = '0'], '/m')"/>
                        <type>AGREGE</type>
                        <xsl:call-template name="meta"/>
                        <bidon> <!-- propriétés pour xsl "bidon" pour chargement dans Oracle -->
                            <lien>464</lien>
                            <xsl:call-template name="zones4XX">
                                            <xsl:with-param name="typePub" select="$typePub" />
                                        </xsl:call-template>
                            <xsl:call-template name="meta">
                                <xsl:with-param name="idSource" select="marc:subfield[@code= '0']"/>
                                <xsl:with-param name="citeDans" select="$PPN"/>
                            </xsl:call-template>
                        </bidon>
                    </relation>
                </xsl:when>
                <xsl:when test="marc:subfield[@code = 't']">
                    <relation>
                        <xsl:attribute name="xref" select="concat($racineId, '/m/464/', position())"/>
                        <type>AGREGE</type>
                        <xsl:call-template name="meta"/>
                        <bidon> <!-- propriétés pour xsl "bidon" pour chargement dans Oracle -->
                            <lien>464</lien>
                            <xsl:call-template name="zones4XX">
                                            <xsl:with-param name="typePub" select="$typePub" />
                                        </xsl:call-template>
                            <xsl:call-template name="meta">
                                <xsl:with-param name="citeDans" select="$PPN"/>
                            </xsl:call-template>
                        </bidon>
                    </relation>
                </xsl:when>
            </xsl:choose>
        </xsl:for-each>
        <!-- RELATION ITEM ou pas... -->
        <xsl:comment>typeManif : <xsl:value-of select="$typeManif"/>
       <xsl:choose>
           <xsl:when test="$typeManif = 'manifSansExemplaire'">
               PAS DE RELATION ITEM
           </xsl:when>
           <xsl:otherwise> 
               ---- relation au(x) Item(s) via 930 ----
           </xsl:otherwise>
       </xsl:choose>
        </xsl:comment>
        <xsl:choose>
            <xsl:when test="$typeManif = 'manifExemplaires'">
                <xsl:for-each select="marc:datafield[@tag = '930'][marc:subfield[@code = '5']]">
                    <xsl:variable name="EPN">
                        <xsl:value-of select="substring-after(marc:subfield[@code = '5'], ':')"/>
                    </xsl:variable>
                    <xsl:comment> EPN <xsl:value-of select="$EPN"/> </xsl:comment>
                    <relation>
                        <xsl:attribute name="xref" select="concat($racineId, '/i/', $EPN)"/>
                        <type>A_POUR_ITEM</type>
                        <xsl:call-template name="meta"/>
                    </relation>
                </xsl:for-each>
            </xsl:when>
            <xsl:otherwise/>
        </xsl:choose>
    </xsl:template>
    <xsl:template name="manifSpec">
        <xsl:param name="type"/>
        <xsl:param name="typePub"/>
        <xsl:param name="typePubSerie"/>
        <xsl:param name="racineId"/>
        <xsl:param name="PPN"/>
        <xsl:param name="typeManif"/>
        <xsl:param name="numManif"/>
        <xsl:param name="nbManif"/>
        <xsl:choose>
            <xsl:when
                test="$type = 'Electronique' and marc:datafield[@tag = '856'][not(marc:subfield[@code = '5'])][marc:subfield[@code = 'u']]">
                <xsl:comment>--- Elec via 856 ---</xsl:comment>
                <xsl:variable name="spec" as="node()*">
                    <xsl:for-each-group
                        select="marc:datafield[@tag = '856'][not(marc:subfield[@code = '5'])]"
                        group-by="marc:subfield[@code = 'u']">
                        <xsl:variable name="uri">
                            <xsl:value-of select="current-grouping-key()"/>
                        </xsl:variable>
                        <xsl:choose>
                            <xsl:when test="current-group()[marc:subfield[@code = 'q']]">
                                <xsl:for-each-group select="current-group()"
                                    group-by="marc:subfield[@code = 'q']">
                                    <specialite>
                                        <xsl:element name="propriete">
                                            <xsl:attribute name="nom" select="'uri'"/>
                                            <xsl:value-of select="$uri"/>
                                        </xsl:element>
                                        <xsl:element name="propriete">
                                            <xsl:attribute name="nom" select="'format'"/>
                                            <xsl:value-of select="current-grouping-key()"/>
                                        </xsl:element>
                                        <xsl:for-each
                                            select="current-group()/marc:subfield[@code = 'z']">
                                            <xsl:element name="propriete">
                                                <xsl:attribute name="nom" select="'noteAcces'"/>
                                                <xsl:value-of select="normalize-space(.)"/>
                                            </xsl:element>
                                        </xsl:for-each>
                                        <xsl:for-each
                                            select="parent::marc:record/marc:datafield[@tag = '010'][marc:subfield[@code = 'a']][marc:subfield[@code = 'b']]">
                                            <xsl:if
                                                test="contains(marc:subfield[@code = 'b'], current-grouping-key())">
                                                <xsl:for-each select="marc:subfield[@code = 'a']">
                                                  <xsl:call-template name="typeIsbn">
                                                  <xsl:with-param name="isbn"
                                                  select="marc:subfield[@code = 'a']"/>
                                                  </xsl:call-template>
                                                </xsl:for-each>
                                            </xsl:if>
                                        </xsl:for-each>
                                    </specialite>
                                </xsl:for-each-group>
                            </xsl:when>
                            <xsl:otherwise>
                                <specialite>
                                    <xsl:element name="propriete">
                                        <xsl:attribute name="nom" select="'uri'"/>
                                        <xsl:value-of select="$uri"/>
                                    </xsl:element>
                                    <xsl:for-each
                                        select="current-group()/marc:subfield[@code = 'z']">
                                        <xsl:element name="propriete">
                                            <xsl:attribute name="nom" select="'noteAcces'"/>
                                            <xsl:value-of select="normalize-space(.)"/>
                                        </xsl:element>
                                    </xsl:for-each>
                                </specialite>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:for-each-group>
                </xsl:variable>
                <xsl:comment>Proprietes specifiques de la manifestation <xsl:value-of select="$numManif"/> </xsl:comment>
                <xsl:choose>
                    <xsl:when test="$numManif = 'manifNotice'">
                        <xsl:for-each-group select="$spec" group-by="propriete[@nom = 'uri']">
                            <xsl:copy-of select="propriete[@nom = 'uri']"/>
                        </xsl:for-each-group>
                        <xsl:for-each-group select="$spec" group-by="propriete[@nom = 'format']">
                            <xsl:copy-of select="propriete[@nom = 'format']"/>
                        </xsl:for-each-group>
                        <xsl:for-each-group
                            select="marc:datafield[@tag = '856'][not(marc:subfield[@code = '5'])]"
                            group-by="marc:subfield[@code = 'z']">
                            <xsl:element name="propriete">
                                <xsl:attribute name="nom" select="'noteAcces'"/>
                                <xsl:value-of select="normalize-space(current-grouping-key())"/>
                            </xsl:element>
                        </xsl:for-each-group>
                        <xsl:for-each-group
                            select="marc:datafield[@tag = '010'][marc:subfield[@code = 'a']]"
                            group-by="marc:subfield[@code = 'a']">
                            <xsl:call-template name="typeIsbn">
                                <xsl:with-param name="isbn" select="current-grouping-key()"/>
                            </xsl:call-template>
                            <xsl:for-each-group select="current-group()[marc:subfield[@code = 'b']]"
                                group-by="marc:subfield[@code = 'b']">
                                <xsl:element name="propriete">
                                    <xsl:attribute name="nom" select="'format'"/>
                                    <xsl:value-of select="current-grouping-key()"/>
                                </xsl:element>
                            </xsl:for-each-group>
                        </xsl:for-each-group>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:copy-of select="$spec[position() = number($numManif)]/*"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:comment>
                    <xsl:choose>
                            <xsl:when test="$type = 'Electronique'">--- Elec via 010 ---</xsl:when>
                            <xsl:otherwise>--- Imprime et autres via 010 ---</xsl:otherwise>
                       </xsl:choose>
                </xsl:comment>
                <xsl:variable name="spec" as="node()*">
                    <xsl:for-each-group
                        select="marc:datafield[@tag = '010'][marc:subfield[@code = 'a']]"
                        group-by="marc:subfield[@code = 'a']">
                        <xsl:variable name="isbn">
                            <xsl:value-of select="current-grouping-key()"/>
                        </xsl:variable>
                        <xsl:choose>
                            <xsl:when test="current-group()[marc:subfield[@code = 'b']]">
                                <xsl:for-each-group select="current-group()"
                                    group-by="marc:subfield[@code = 'b']">
                                    <specialite>
                                        <xsl:call-template name="typeIsbn">
                                            <xsl:with-param name="isbn" select="$isbn"/>
                                        </xsl:call-template>
                                        <xsl:element name="propriete">
                                            <xsl:attribute name="nom" select="'format'"/>
                                            <xsl:value-of select="current-grouping-key()"/>
                                        </xsl:element>
                                    </specialite>
                                </xsl:for-each-group>
                            </xsl:when>
                            <xsl:otherwise>
                                <specialite>
                                    <xsl:call-template name="typeIsbn">
                                        <xsl:with-param name="isbn" select="$isbn"/>
                                    </xsl:call-template>
                                </specialite>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:for-each-group>
                    <xsl:if test="$type != 'Electronique'">
                        <xsl:if
                            test="marc:datafield[@tag = '010'][not(marc:subfield[@code = 'a'])][contains(lower-case(marc:subfield[@code = 'b'][1]), 'br')]">
                            <specialite>
                                <xsl:element name="propriete">
                                    <xsl:attribute name="nom" select="'format'"/>
                                    <xsl:value-of select="'broché'"/>
                                </xsl:element>
                            </specialite>
                        </xsl:if>
                        <xsl:if
                            test="marc:datafield[@tag = '010'][not(marc:subfield[@code = 'a'])][contains(lower-case(marc:subfield[@code = 'b'][1]), 'rel')]">
                            <specialite>
                                <xsl:element name="propriete">
                                    <xsl:attribute name="nom" select="'format'"/>
                                    <xsl:value-of select="'relié'"/>
                                </xsl:element>
                            </specialite>
                        </xsl:if>
                    </xsl:if>
                </xsl:variable>
                <xsl:comment>Proprietes specifiques de la manifestation <xsl:value-of select="$numManif"/> </xsl:comment>
                <xsl:choose>
                    <xsl:when test="$numManif = 'manifNotice'">
                        <xsl:for-each-group select="$spec" group-by="propriete[@nom = 'isbn10']">
                            <xsl:copy-of select="propriete[@nom = 'isbn10']"/>
                        </xsl:for-each-group>
                        <xsl:for-each-group select="$spec" group-by="propriete[@nom = 'isbn13']">
                            <xsl:copy-of select="propriete[@nom = 'isbn13']"/>
                        </xsl:for-each-group>
                        <xsl:for-each-group select="$spec" group-by="propriete[@nom = 'format']">
                            <xsl:copy-of select="propriete[@nom = 'format']"/>
                        </xsl:for-each-group>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:copy-of select="$spec[position() = number($numManif)]/*"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template name="typeIsbn">
        <xsl:param name="isbn"/>
        <xsl:choose>
            <xsl:when test="string-length(replace($isbn, '[^0-9]', '')) = 13">
                <propriete nom="ISBN13">
                    <xsl:value-of select="normalize-space($isbn)"/>
                </propriete>
            </xsl:when>
            <xsl:when test="string-length(replace($isbn, '[^0-9]', '')) = 10">
                <propriete nom="ISBN10">
                    <xsl:value-of select="normalize-space($isbn)"/>
                </propriete>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    <xsl:template name="rameauVedette">
        <xsl:param name="typeVedette"/>
        <xsl:choose>
            <xsl:when test="$typeVedette = '600'">
                <type lrm="PERSONNE">PERSONNE</type>
            </xsl:when>
            <xsl:when test="$typeVedette = '601'">
                <type lrm="COLLECTIVITE">COLLECTIVITE</type>
            </xsl:when>
            <xsl:when test="$typeVedette = '602'">
                <type lrm="PERSONNE">PERSONNE</type>
            </xsl:when>
            <xsl:when test="$typeVedette = '604'">
                <type lrm="OEUVRE">OEUVRE</type>
            </xsl:when>
            <xsl:when test="$typeVedette = '605'">
                <type lrm="OEUVRE">OEUVRE</type>
            </xsl:when>
            <xsl:when test="$typeVedette = '606' or '608'">
                <type lrm="CONCEPT">CONCEPT</type>
            </xsl:when>
            <xsl:when test="$typeVedette = '607'">
                <type lrm="LIEU">LIEU</type>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    <xsl:template name="rameauNomen">
        <xsl:param name="typeVedette"/>
        <xsl:choose>
            <xsl:when test="$typeVedette = '600'">
                <type>PERSONNE</type>
            </xsl:when>
            <xsl:when test="$typeVedette = '601'">
                <type>COLLECTIVITE</type>
            </xsl:when>
            <xsl:when test="$typeVedette = '602'">
                <type>PERSONNE</type>
            </xsl:when>
            <xsl:when test="$typeVedette = '604'">
                <type>TITRE</type>
            </xsl:when>
            <xsl:when test="$typeVedette = '605'">
                <type>TITRE</type>
            </xsl:when>
            <xsl:when test="$typeVedette = '606' or '608'">
                <type>NOM_COMMUN</type>
            </xsl:when>
            <xsl:when test="$typeVedette = '607'">
                <type>NOM_LIEU</type>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    <xsl:template name="contrib_relation">
        <xsl:param name="mode"/>
        <xsl:param name="PPN"/>
        <xsl:param name="idMention"/>
        <xsl:param name="position"/>
        <xsl:param name="idref" select="marc:subfield[@code = '3']"/>
        <!--<xsl:param name="codefct"/>-->
        <xsl:choose>
            <xsl:when test="$mode = 'relation_agent'">
                <relation>
                    <xsl:variable name="idref" select="concat('http://www.idref.fr/', $idref)"/>
                    <xsl:attribute name="xref">
                        <xsl:value-of select="$idref"/>
                    </xsl:attribute>
                    <type>A_POUR_CONTRIBUTEUR</type>
                    <xsl:call-template name="meta"/>
                    <xsl:choose>
                        <xsl:when test="self::node()[starts-with(@tag, '7')]">
                            <xsl:for-each select="marc:subfield[@code = '4' and text() != '']">
                                <xsl:call-template name="role">
                                    <xsl:with-param name="codefct" select="."/>
                                </xsl:call-template>
                            </xsl:for-each>
                        </xsl:when>
                        <xsl:when test="self::node()[starts-with(@code, 'c')]">
                            <!--self::node() correspond à zone 210 ou 214 :dont on prend le $c-->
                            <xsl:call-template name="role">
                                <xsl:with-param name="codefct" select="'650'"/>
                            </xsl:call-template>
                        </xsl:when>
                    </xsl:choose>
                </relation>
            </xsl:when>
            <xsl:when test="$mode = 'relation_mention'">
                <relation>
                    <type>A_POUR_MENTION</type>
                    <xsl:call-template name="meta"/>
                    <Entite id="{$idMention}">
                        <type lrm="CONTEXTE">CONTEXTE</type>
                        <type>CONTRIBUTION</type>
                        <xsl:call-template name="meta">
                            <xsl:with-param name="idSource" select="$PPN"/>
                        </xsl:call-template>
                        <xsl:choose>
                            <xsl:when test="self::node()[starts-with(@tag, '7')]">
                                <xsl:for-each select="marc:subfield[@code = '4' and text() != '']">
                                    <xsl:call-template name="role">
                                        <xsl:with-param name="codefct" select="."/>
                                    </xsl:call-template>
                                </xsl:for-each>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:call-template name="role">
                                    <xsl:with-param name="codefct" select="'650'"/>
                                </xsl:call-template>
                            </xsl:otherwise>
                        </xsl:choose>
                        <relation xref="{$idMention}/contrib/nomen">
                            <type>A_POUR_MENTION_DE_CONTRIBUTEUR</type>
                            <xsl:call-template name="meta"/>
                        </relation>
                    </Entite>
                </relation>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    <!-- pour items => rcr et rcr/fonds => rcr -->
    <xsl:template name="contrib_relation_rcr">
        <xsl:param name="RCR"/>
        <relation>
            <xsl:variable name="xref" select="concat('http://www.abes.fr/rcr/', $RCR)"/>
            <xsl:attribute name="xref">
                <xsl:value-of select="$xref"/>
            </xsl:attribute>
            <type>A_POUR_CONTRIBUTEUR</type>
            <propriete nom="ROLE">Possesseur</propriete>
            <xsl:call-template name="meta"/>
        </relation>
    </xsl:template>
    <!-- Nomens -->
    <xsl:template name="nomen">
        <xsl:param name="type"/>
        <xsl:param name="typeAcces"/>
        <type lrm="NOMEN">NOMEN</type>
        <type>
            <xsl:value-of select="$type"/>
        </type>
        <propriete nom="TYPE_ACCES">
            <xsl:value-of select="$typeAcces"/>
        </propriete>
        <xsl:choose>
            <xsl:when test="$type = 'PERSONNE'">
                <xsl:variable name="nom" select="normalize-space(marc:subfield[@code = 'a'])"/>
                <xsl:variable name="prenom" select="normalize-space(marc:subfield[@code = 'b'])"/>
                <propriete nom="NOM">
                    <xsl:value-of select="$nom"/>
                </propriete>
                <propriete nom="PRENOM">
                    <xsl:value-of select="$prenom"/>
                </propriete>
                <propriete nom="VALEUR">
                    <xsl:value-of select="concat($nom, ',&#x20;', $prenom)"/>
                </propriete>
            </xsl:when>
            <xsl:when test="$type = 'COLLECTIVITE'">
                <propriete nom="VALEUR">
                    <xsl:choose>
                        <xsl:when test="self::marc:datafield[starts-with(@tag, '7')]">
                            <xsl:value-of select="normalize-space(marc:subfield[@code = 'a'])"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="normalize-space(.)"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </propriete>
            </xsl:when>
            <xsl:otherwise>
                <propriete nom="VALEUR">
                    <xsl:value-of select="normalize-space(marc:subfield[@code = 'a'])"/>
                </propriete>
            </xsl:otherwise>
        </xsl:choose>
        <!--        <propriete nom="LANGUE">français</propriete>-->
        <propriete nom="ALPHABET">latin</propriete>
    </xsl:template>
    <!-- Conversion des codes de fonction en rôles -->
    <xsl:template name="role">
        <xsl:param name="codefct"/>
        <xsl:variable name="rolemap"
            >;010=Adaptateur;070=Auteur;080=Préfacier;257=Continuateur;280=Dédicataire;320=Donateur;340=Editeur&#x20;scientifique;390=Ancien&#x20;possesseur;395=Fondateur;440=Illustrateur;610=Imprimeur;650=Editeur&#x20;commercial;651=Directeur&#x20;de&#x20;publication;730=Traducteur;</xsl:variable>
        <xsl:variable name="role"
            select="substring-before(substring-after($rolemap, concat(';', $codefct, '=')), ';')"/>
        <propriete nom="ROLE">
            <xsl:choose>
                <xsl:when test="$role != ''">
                    <xsl:value-of select="$role"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>Contributeur</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </propriete>
    </xsl:template>
    <xsl:template name="meta">
        <xsl:param name="idSource"/>
        <xsl:param name="citeDans"/>
        <propriete nom="META_SOURCE">MARC</propriete>
        <propriete nom="META_ACTEUR">XSL Pivot</propriete>
        <xsl:if test="$idSource != ''">
            <propriete nom="ID_SOURCE">
                <xsl:value-of select="$idSource"/>
            </propriete>
        </xsl:if>
        <xsl:if test="$citeDans != ''">
            <propriete nom="CITE_DANS">
                <xsl:value-of select="$citeDans"/>
            </propriete>
        </xsl:if>
    </xsl:template>
    <xsl:template name="perio">
        <xsl:param name="code"/>
        <xsl:variable name="codemap"
            >;a=Quotidien;b=Bihebdomadaire;c=Hebdomadaire;d=Toutes&#x20;les&#x20;deux
            semaines;e=Deux&#x20;fois&#x20;par&#x20;mois;f=Mensuel;g=Bimestriel;h=Trimestriel;i=Trois&#x20;fois&#x20;par&#x20;an;j=Semestriel;k=Annuel;l=Bisannuel;m=Triennal;n=Trois&#x20;fois&#x20;par&#x20;semaine;o=Trois&#x20;fois&#x20;par&#x20;mois;p=Mise&#x20;à&#x20;jour&#x20;en&#x20;continu;u=Inconnue;y=Sans
            périodicité;z=Autre;</xsl:variable>
        <xsl:value-of
            select="substring-before(substring-after($codemap, concat(';', $code, '=')), ';')"/>
    </xsl:template>
    <xsl:template name="codeEcriture">
        <xsl:param name="code"/>
        <xsl:variable name="codemap"
            >;ba=latin;ca=cyrillique;da=japonais&#x20;-&#x20;écriture&#x20;non&#x20;définie;db=japonais&#x20;-&#x20;Kanji;dc=japonais&#x20;-&#x20;Kana;ea=caractères&#x20;chinois&#x20;(chinois,&#x20;japonais,&#x20;coréen);fa=arabe;ga=grec;ha=hébreu;ia=thaï;ja=devanagari;ka=coréen;la=tamoul;ma=géorgien;mb=arménien;zz=autre;</xsl:variable>
        <xsl:value-of
            select="substring-before(substring-after($codemap, concat(';', $code, '=')), ';')"/>
    </xsl:template>
    <xsl:template name="codeLangue">
        <xsl:param name="code"/>
        <xsl:variable name="codemap"
            >;fre=français;eng=anglais;ger=allemand;spa=espagnol;ita=italien;por=portugais;dut=néerlandais;lat=latin;gre=grec;rus=russe;cat=catalan;</xsl:variable>
        <xsl:choose>
            <xsl:when test="contains($codemap, concat(';', $code, '='))">
                <xsl:value-of
                    select="substring-before(substring-after($codemap, concat(';', $code, '=')), ';')"
                />
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>autre</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template name="zones4XX">
        <xsl:param name="typePub"/>
        <xsl:choose>
            <xsl:when test="$typePub = 'MONOGRAPHIE'">
                <type/>
            </xsl:when>
            <xsl:otherwise>
                <type>_AGREGATIVE</type>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:for-each select="marc:subfield[@code = 't']">
            <titreBidon>
                <xsl:value-of select="."/>
            </titreBidon>
        </xsl:for-each>
        <xsl:for-each select="marc:subfield[@code = 'f']">
            <mentionRespBidon>
                <xsl:value-of select="."/>
            </mentionRespBidon>
        </xsl:for-each>
        <xsl:for-each select="marc:subfield[@code = 'g']">
            <mentionRespBisBidon>
                <xsl:value-of select="."/>
            </mentionRespBisBidon>
        </xsl:for-each>
        <xsl:for-each select="marc:subfield[@code = 'x']">
            <issnBidon>
                <xsl:value-of select="."/>
            </issnBidon>
        </xsl:for-each>
        <xsl:for-each select="marc:subfield[@code = 'y']">
            <isbnBidon>
                <xsl:value-of select="."/>
            </isbnBidon>
        </xsl:for-each>
    </xsl:template>
</xsl:stylesheet>
