<?xml version="1.0" encoding="UTF-8"?>
<!-- Documentation humaine : https://github.com/abes-esr/abes-format-pivot/blob/main/documentation/documentatation_humaine_XSL_marc2pivot.md-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" version="2.0">
    <xsl:output encoding="UTF-8" method="xml" indent="yes"/>
    <xsl:strip-space elements="*"/>
    <xsl:template match="/">
        <CollWemi>
            <xsl:apply-templates select="//record"> </xsl:apply-templates>
        </CollWemi>
    </xsl:template>
    <xsl:template match="record">
        <xsl:variable name="PPN" select="controlfield[@tag = 001]"/>
        <xsl:variable name="racineId">
            <xsl:value-of select="concat('http://www.abes.fr/', $PPN)"/>
        </xsl:variable>
        <xsl:variable name="OeuvreId">
            <xsl:value-of select="concat($racineId, '/w')"/>
        </xsl:variable>
        <Entite id="{$OeuvreId}">
            <type lrm="OEUVRE">OEUVRE</type>
            <xsl:comment>---propriétés niveau Oeuvre ----</xsl:comment>
            <!-- Langue (niveau oeuvre) -->
            <xsl:for-each select="datafield[@tag = '101']/subfield[@code = 'a'][text() != '']">
                <propriete nom="LANGUE">
                    <xsl:call-template name="codeLangue">
                        <xsl:with-param name="code" select="normalize-space(.)"/>
                    </xsl:call-template>
                    <!--<xsl:value-of select="normalize-space(text())"/>-->
                </propriete>
            </xsl:for-each>
            <!-- indexation traitée à plat "type mot clef", il faudrait une construction "type réferentiel" pour dire schema, version, langue + rendre le n° d'ordre dans la notice-->
            <xsl:for-each select="datafield[@tag = '676']/subfield[@code = 'a'][text() != '']">
                <propriete nom="INDICE_DEWEY">
                    <xsl:value-of select="normalize-space(text())"/>
                </propriete>
            </xsl:for-each>
            <xsl:for-each select="datafield[@tag = '330']/subfield[@code = 'a'][text() != '']">
                <propriete nom="RESUME">
                    <xsl:value-of select="normalize-space(text())"/>
                </propriete>
            </xsl:for-each>
            <xsl:call-template name="meta">
                <xsl:with-param name="idSource" select="$PPN"/>
            </xsl:call-template>
            <xsl:comment>---relations niveau Oeuvre ----</xsl:comment>
            <!-- Nomen titre : provisoirement o nprend le titre de la manif, le 200$a -->
            <xsl:for-each
                select="datafield[@tag = '241' or @tag = '231'][subfield[@code = 'a' or @code = 't' and text() != '']]">
                <relation>
                    <xsl:attribute name="xref" select="concat($racineId, '/w/nomen/', position())"/>
                    <type>A_POUR_NOMEN</type>
                    <xsl:call-template name="meta"/>
                </relation>
            </xsl:for-each>
            <!-- RELATION Contributeurs (niveau oeuvre) -->
            <xsl:variable name="roles">010 - 070 - 257 - 340 - 395 - 440 - 651</xsl:variable>
            <xsl:for-each
                select="datafield[@tag = '501' or @tag = '511' or @tag = '521'][subfield[@code = '3']][subfield[@code = '4'][contains($roles, text())]]">
                <xsl:comment>---relation contributeur niveau Oeuvre ---</xsl:comment>
                <!--<xsl:variable name="codefct"> 
                            <xsl:value-of select="subfield[@code = '4'][1]"/>
                        </xsl:variable>-->
                <!-- test suppléméntaire pour le code de fct illustrateur : si en 702, pas dans l'oeuvre. Pour généraliser il faudrait deux variables role et cherche séparément dans 700/701/710/711/720/721, et 702/712/722-->
                <xsl:call-template name="contrib_relation">
                    <xsl:with-param name="PPN" select="$PPN"/>
                    <xsl:with-param name="mode" select="'relation_agent'"/>
                    <!--<xsl:with-param name="codefct" select="$codefct"/>-->
                </xsl:call-template>
            </xsl:for-each>
            <!-- Zones troubles de l'indexation -->
            <xsl:for-each
                select="datafield[@tag = '600' or @tag = '601' or @tag = '602' or @tag = '604' or @tag = '605' or @tag = '606' or @tag = '607' or @tag = '608']">
                <xsl:variable name="referentiel">
                    <xsl:value-of
                        select="normalize-space(lower-case(subfield[@code = '2'][1]))"/>
                </xsl:variable>
                <xsl:choose>
                    <!-- RELATION A_POUR_SUJET quand absence de lien (sans @code = '3'). On ne garde que la tête de vedette (pas de construction "BOITE_SUJETS") 
                        TODO ???? -->
                    <xsl:when test="not(subfield[@code = '3'])">
                        <relation>
                            <xsl:attribute name="xref">
                                <xsl:value-of select="concat($racineId, '/w/sujet/', position())"/>
                            </xsl:attribute>
                            <type>A_POUR_SUJET</type>
                            <xsl:call-template name="meta"/>
                        </relation>
                    </xsl:when>
                    <xsl:when test="subfield[@code = '3']">
                        <relation>
                            <xsl:choose>
                                <xsl:when test="count(subfield[@code = '3']) = 1">
                                    <xsl:attribute name="xref">
                                        <xsl:value-of
                                            select="concat('http://www.idref.fr/', subfield[@code = '3'])"
                                        />
                                    </xsl:attribute>
                                    <!-- RELATION A_POUR_SUJET avec lien et pas de subdivision (1 seul @code = '3')-->
                                    <type>A_POUR_SUJET</type>
                                    <xsl:call-template name="meta"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <!-- RELATION2 A_POUR_INDEXATION = BOITE_SUJETS avec lien et subdivision(s) (plusieurs @code = '3')-->
                                    <type>A_POUR_INDEXATION</type>
                                    <Entite id="{concat($racineId, '/w/sujet/', position())}">
                                        <type lrm="CONTEXTE">CONTEXTE</type>
                                        <type>BOITE_SUJETS</type>
                                        <xsl:for-each select="subfield[@code = '2']">
                                            <propriete nom="REFERENTIEL">
                                                <xsl:value-of select="$referentiel"/>
                                            </propriete>
                                        </xsl:for-each>
                                        <xsl:call-template name="meta">
                                            <xsl:with-param name="idSource" select="$PPN"/>
                                        </xsl:call-template>
                                        <!-- A_POUR_SUJET_PRINCIPAL appel template nommé rameau pour relation au sujet principal = vedette-->
                                        <xsl:for-each
                                            select="subfield[@code = '3'][position() = 1 and text() != '']">
                                            <xsl:call-template name="rameau">
                                                <xsl:with-param name="ppnRameau" select="text()"/>
                                                <xsl:with-param name="referentiel"
                                                  select="$referentiel"/>
                                                <xsl:with-param name="mode" select="'relation'"/>
                                                <xsl:with-param name="typeSub" select="'vedette'"/>
                                            </xsl:call-template>
                                        </xsl:for-each>
                                        <!-- A_POUR_SPECIFICATION_SUJET/LIEU/TEMPS appel template nommé rameau pour relation au(x) subdivivsion(s) -->
                                        <xsl:for-each
                                            select="subfield[@code = '3'][position() > 1 and text() != '']">
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
        </Entite>
        <!-- Entités de regroupement (notices 500). Si pas de lien, on fait un nomen titre supplémentaire-->
        <xsl:for-each select="datafield[@tag = '500']">
            <Entite>
                <xsl:choose>
                    <xsl:when test="subfield[@code = '3'] != ''">
                        <xsl:attribute name="id"
                            select="concat('http://www.idref.fr/', subfield[@code = '3'])"/>
                        <type lrm="ENSEMBLE">ENSEMBLE</type>
                        <type>OEUVRES500</type>
                        <xsl:call-template name="meta">
                            <xsl:with-param name="idSource" select="subfield[@code = '3']"/>
                            <xsl:with-param name="citeDans" select="$PPN"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:when test="subfield[@code = 'a'] != ''">
                        <xsl:attribute name="id"
                            select="concat($racineId, '/w/500/nomen', position())"/>
                        <type lrm="NOMEN">NOMEN</type>
                        <type>TITRE</type>
                        <type>TITRE_UNIFORME</type>
                        <propriete nom="TYPE_ACCES">paa</propriete>
                        <propriete nom="VALEUR">
                            <xsl:value-of select="normalize-space(subfield[@code = 'a'])"/>
                            <xsl:for-each select="subfield[@code = 'i' and text() != '']">
                                <xsl:value-of select="concat(' : ', normalize-space(.))"/>
                            </xsl:for-each>
                        </propriete>
                        <xsl:for-each select="subfield[@code = '7' and text() != '']">
                            <propriete nom="ALPHABET">
                                <xsl:comment>valeur code alphabet <xsl:value-of select="substring(.,1,2)"/></xsl:comment>
                                <xsl:call-template name="codeEcriture">
                                    <xsl:with-param name="code" select="substring(.,1,2)"/>
                                </xsl:call-template>
                            </propriete>
                        </xsl:for-each>
                        <xsl:for-each select="subfield[@code = 'm']">
                            <propriete nom="LANGUE">
                                <xsl:call-template name="codeLangue">
                                    <xsl:with-param name="code" select="normalize-space(.)"/>
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
        <xsl:comment>---- nomen titre de l'oeuvre ----</xsl:comment>
        <xsl:for-each
            select="datafield[@tag = '231' or @tag = '241'][subfield[@code = 't' or @code = 'a' and text() != '']]">
            <Entite>
                <xsl:attribute name="id" select="concat($racineId, '/w/nomen/', position())"/>
                <type lrm="NOMEN">NOMEN</type>
                <type>TITRE</type>
                <propriete nom="TYPE_ACCES">ng</propriete>
                <propriete nom="VALEUR">
                    <xsl:for-each select="subfield[text() != '']">
                        <xsl:choose>
                            <xsl:when test="@code = 't'">
                                <xsl:if test="count(preceding-sibling::subfield[@code = 't']) > 0">
                                    <xsl:text>.&#x20;</xsl:text>
                                </xsl:if>
                                <xsl:value-of select="normalize-space(.)"/>
                            </xsl:when>
                            <xsl:when test="@code = 'a'">
                                <xsl:if test="count(preceding-sibling::subfield[@code = 'a']) > 0">
                                    <xsl:text>.&#x20;</xsl:text>
                                </xsl:if>
                                <xsl:value-of select="normalize-space(.)"/>
                            </xsl:when>
                            <xsl:when test="@code = 'i'">
                                <xsl:value-of select="concat('. ', normalize-space())"/>
                            </xsl:when>
                            <xsl:when test="@code = 'k'">
                                <xsl:value-of select="concat(' (', normalize-space(), ')')"/>
                            </xsl:when>
                            <xsl:when test="@code = 'r'">
                                <xsl:value-of select="concat(', ', normalize-space(), ')')"/>
                            </xsl:when>
                            <xsl:when test="@code = 's'">
                                <xsl:value-of select="concat('. ', normalize-space(), ')')"/>
                            </xsl:when>
                            <xsl:when test="@code = 'u'">
                                <xsl:value-of select="concat(', ', normalize-space(), ')')"/>
                            </xsl:when>
                            <xsl:otherwise/>
                        </xsl:choose>
                    </xsl:for-each>
                    <xsl:for-each select="subfield[@code = 'f' and text() != '']">
                        <xsl:value-of select="concat(' / ', normalize-space(.))"/>
                    </xsl:for-each>
                    <xsl:for-each select="subfield[@code = 'g' and text() != '']">
                        <xsl:value-of select="concat(' ; ', normalize-space(.))"/>
                    </xsl:for-each>
                </propriete>
                <xsl:for-each select="subfield[@code = '7' and text() != '']">
                    <propriete nom="ALPHABET">
                        <xsl:comment>valeur code alphabet <xsl:value-of select="substring(.,1,2)"/></xsl:comment>
                        <xsl:call-template name="codeEcriture">
                            <xsl:with-param name="code" select="substring(.,1,2)"/>
                        </xsl:call-template>
                    </propriete>
                </xsl:for-each>
                <xsl:if
                    test="not(subfield[@code = '6']) and //datafield[@tag = '101'][subfield[@code = 'g'] != '']">
                    <xsl:for-each select="//datafield[@tag = '101']/subfield[@code = 'g']">
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
        <!-- ENTITE 464 AGREGE (OEUVRE)-->
        <!--<xsl:for-each select="datafield[(@tag = '464')]">
            <xsl:choose>
                <!-\- 464 $0 AGREGE-\->
                <xsl:when test="subfield[@code = '0']">
                    <Entite>
                        <xsl:attribute name="id"
                            select="concat('http://www.abes.fr/', subfield[@code = '0'], '/w')"/>
                        <type lrm="OEUVRE">OEUVRE</type>
                        <xsl:call-template name="meta">
                            <xsl:with-param name="idSource" select="subfield[@code = '0']"/>
                            <xsl:with-param name="citeDans" select="$PPN"/>
                        </xsl:call-template>
                    </Entite>
                </xsl:when>
                <!-\- ENTITE 464 $t CONTIENT -\->
                <xsl:when test="subfield[@code = 't'][text() != '']">
                    <Entite>
                        <xsl:attribute name="id" select="concat($racineId, '/m/464/', position())"/>
                        <type lrm="OEUVRE">OEUVRE</type>
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
                            <xsl:value-of select="normalize-space(subfield[@code = 't'])"/>
                        </propriete>
                        <xsl:call-template name="meta">
                            <xsl:with-param name="idSource" select="$PPN"/>
                        </xsl:call-template>
                    </Entite>
                </xsl:when>
            </xsl:choose>
        </xsl:for-each>-->
        <!-- ENTITE liée par A_POUR_SUJET sans @code = '3'-->
        <xsl:for-each
            select="datafield[@tag = '600' or @tag = '601' or @tag = '602' or @tag = '604' or @tag = '605' or @tag = '606' or @tag = '607' or @tag = '608'][not(subfield[@code = '3'])][subfield[@code = 'a']/text() != '']">
            <xsl:variable name="referentiel">
                <xsl:value-of
                    select="normalize-space(lower-case(subfield[@code = '2'][1]))"/>
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
                    <xsl:value-of select="normalize-space(subfield[@code = 'a'][1])"
                    />
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
            select="datafield[@tag = '600' or @tag = '601' or @tag = '602' or @tag = '604' or @tag = '605' or @tag = '606' or @tag = '607' or @tag = '608']/subfield[@code = '3'][position() = 1 and text() != '']">
            <xsl:variable name="referentiel">
                <xsl:value-of
                    select="normalize-space(lower-case(parent::datafield/subfield[@code = '2'][1]))"/>
            </xsl:variable>
            <xsl:call-template name="rameau">
                <xsl:with-param name="ppnRameau" select="text()"/>
                <xsl:with-param name="referentiel" select="$referentiel"/>
                <xsl:with-param name="mode" select="'entite'"/>
                <xsl:with-param name="typeSub" select="'vedette'"/>
                <xsl:with-param name="typeVedette" select="parent::datafield/@tag"/>
            </xsl:call-template>
        </xsl:for-each>
        <!-- ENTITE liée par A_POUR_SPECIFICATION_SUJET/LIEU/TEMPS = subdivision-->
        <xsl:for-each
            select="datafield[@tag = '600' or @tag = '601' or @tag = '602' or @tag = '604' or @tag = '605' or @tag = '606' or @tag = '607' or @tag = '608']/subfield[@code = '3'][position() > 1 and text() != '']">
            <xsl:variable name="referentiel">
                <xsl:value-of
                    select="normalize-space(lower-case(parent::datafield/subfield[@code = '2'][1]))"
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
        <xsl:variable name="roles">010 - 070 - 080 - 257 - 280 - 320 - 340 - 390 - 395 - 440 - 610 -
            650 - 651 - 730</xsl:variable>
        <xsl:for-each
            select="datafield[@tag = '501' or @tag = '511' or @tag = '521'][subfield[@code = '4']][subfield[@code = 'a']/text() != '']">
            <xsl:variable name="typeEntite">
                <xsl:choose>
                    <xsl:when test="@tag = '501'">
                        <xsl:text>PERSONNE</xsl:text>
                    </xsl:when>
                    <xsl:when test="@tag = '511'">
                        <xsl:text>COLLECTIVITE</xsl:text>
                    </xsl:when>
                    <xsl:when test="@tag = '521'">
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
                    test="subfield[@code = '3'] and subfield[@code = '4'][contains($roles, text())]">
                    <xsl:comment>  ---- Entite AGENT AUTORITE niveau Oeuvre</xsl:comment>
                    <xsl:variable name="idref"
                        select="concat('http://www.idref.fr/', subfield[@code = '3'])"/>
                    <Entite>
                        <xsl:attribute name="id">
                            <xsl:value-of select="$idref"/>
                        </xsl:attribute>
                        <type lrm="AGENT">AGENT</type>
                        <type>
                            <xsl:value-of select="$typeEntite"/>
                        </type>
                        <xsl:call-template name="meta">
                            <xsl:with-param name="idSource" select="subfield[@code = '3']"/>
                            <xsl:with-param name="citeDans" select="$PPN"/>
                        </xsl:call-template>
                        <relation xref="{concat($idref,'/nomen')}">
                            <type>A_POUR_NOMEN</type>
                            <xsl:call-template name="meta"/>
                        </relation>
                    </Entite>
                    <xsl:comment>---- Entite NOMEN AGENT AUTORITE niveau Oeuvre</xsl:comment>
                    <Entite id="{concat($idref,'/nomen')}">
                        <xsl:call-template name="nomen">
                            <xsl:with-param name="type" select="$typeNomen"/>
                            <xsl:with-param name="typeAcces" select="'paa'"/>
                        </xsl:call-template>
                        <xsl:call-template name="meta">
                            <xsl:with-param name="idSource" select="subfield[@code = '3']"/>
                            <xsl:with-param name="citeDans" select="$PPN"/>
                        </xsl:call-template>
                    </Entite>
                </xsl:when>
            </xsl:choose>
        </xsl:for-each>

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
        <xsl:param name="idref" select="subfield[@code = '3']"/>
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
                        <xsl:when test="self::node()[@tag = '501' or @tag = '511' or @tag = '521']">
                            <xsl:for-each select="subfield[@code = '4' and text() != '']">
                                <xsl:call-template name="role">
                                    <xsl:with-param name="codefct" select="."/>
                                </xsl:call-template>
                            </xsl:for-each>
                        </xsl:when>
                        <xsl:when test="self::node()[starts-with(@code, 'c')]">
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
                                <xsl:for-each select="subfield[@code = '4' and text() != '']">
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
                <xsl:variable name="nom" select="normalize-space(subfield[@code = 'a'])"/>
                <xsl:variable name="prenom" select="normalize-space(subfield[@code = 'b'])"/>
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
                    <xsl:value-of select="normalize-space(subfield[@code = 'a'])"/>
                </propriete>
            </xsl:when>
            <xsl:otherwise>
                <propriete nom="VALEUR">
                    <xsl:value-of select="normalize-space(subfield[@code = 'a'])"/>
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
</xsl:stylesheet>
