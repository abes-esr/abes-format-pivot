<?xml version="1.0" encoding="UTF-8"?>
<!-- Documentation humaine https://github.com/abes-esr/abes-format-pivot/blob/main/documentation/documentation_humaine_XSL_tef2pivot.md-->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:mets="http://www.loc.gov/METS/"
    xmlns:xlink="http://www.w3.org/1999/xlink"
    xmlns:metsRights="http://cosimo.stanford.edu/sdr/metsrights/"
    xmlns:mads="http://www.loc.gov/mads/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:dcterms="http://purl.org/dc/terms/"
    xmlns:tef="http://www.abes.fr/abes/documents/tef"
    exclude-result-prefixes="xs mets xlink     metsRights mads xsi dc dcterms tef" version="2.0">
    <xsl:output encoding="UTF-8" method="xml" indent="yes"/>
    <xsl:strip-space elements="*"/>

    <xsl:template match="/">
        <CollWemi>
            <xsl:apply-templates select="//mets:mets "> </xsl:apply-templates>
        </CollWemi>
    </xsl:template>  

    <xsl:template match="mets:mets ">
        <xsl:variable name="nnt"
            select="normalize-space(.//tef:thesisAdmin/dc:identifier[@xsi:type = 'tef:NNT'])"/>
    
        <xsl:variable name="racineId" select="concat('http://www.abes.fr/', $nnt)"/>
        <xsl:variable name="langue">
            <xsl:call-template name="langue">
                <xsl:with-param name="langue" select=".//dc:language"/>
            </xsl:call-template>
        </xsl:variable>
        <Wemi>
            <xsl:attribute name="id" select="concat($racineId, '/wemi')"/>
            <xsl:apply-templates
                select="mets:dmdSec/mets:mdWrap[@OTHERMDTYPE = 'tef_desc_these']/mets:xmlData/tef:thesisRecord"
            >
                <xsl:with-param name="racineId" select="$racineId"></xsl:with-param>
                <xsl:with-param name="langue" select="$langue"></xsl:with-param>
                <xsl:with-param name="nnt" select="$nnt"></xsl:with-param>
            </xsl:apply-templates>
        </Wemi>
    </xsl:template>
    <xsl:template match="tef:thesisRecord">
        <xsl:param name="racineId"/>
        <xsl:param name="langue"/>
        <xsl:param name="nnt" />
        <Entite id="{concat($racineId, '/w')}">
            <type lrm="OEUVRE">OEUVRE</type>
            <type>MONOGRAPHIE</type>
            <type>THESE</type>
            <xsl:call-template name="meta">
                <xsl:with-param name="nnt" select="$nnt"/>
                <xsl:with-param name="id" select="$nnt"/>
            </xsl:call-template>
            <propriete nom="NNT">
                <xsl:value-of select="$nnt"/>
            </propriete>
            <propriete nom="THESE_PID">
                <xsl:value-of select="concat('http://www.theses.fr/', $nnt)"/>
            </propriete>
            <xsl:for-each
                select="ancestor::mets:mets//tef:thesisAdmin/tef:thesis.degree/tef:thesis.degree.discipline[text() != '']">
                <propriete nom="DISCIPLINE">
                    <xsl:value-of select="normalize-space(.)"/>
                </propriete>
                <propriete nom="LANGUE">
                    <xsl:value-of select="$langue"/>
                </propriete>
            </xsl:for-each>
            <xsl:for-each select="ancestor::mets:mets//tef:thesisAdmin/dcterms:dateAccepted[text() != '']">
                <propriete nom="DATE_SOUTENANCE">
                    <xsl:value-of select="normalize-space(.)"/>
                </propriete>
            </xsl:for-each>
            <xsl:for-each select="dcterms:abstract[text() != '']">
                <propriete nom="RESUME">
                    <xsl:attribute name="lang">
                        <xsl:call-template name="lang">
                            <xsl:with-param name="lang" select="@xml:lang"/>
                        </xsl:call-template>
                    </xsl:attribute>
                    <xsl:value-of select="normalize-space(.)"/>
                </propriete>
            </xsl:for-each>
            <xsl:for-each select="dc:subject[text() != '']">
                <propriete nom="KEYWORD">
                    <xsl:attribute name="lang">
                        <xsl:call-template name="lang">
                            <xsl:with-param name="lang" select="@xml:lang"/>
                        </xsl:call-template>
                    </xsl:attribute>
                    <xsl:value-of select="normalize-space(.)"/>
                </propriete>
            </xsl:for-each>
            <!-- nb: dc:title est obligatoire et non répétable-->
            <relation xref="{concat($racineId, '/w/nomen/1')}">
                <type>A_POUR_NOMEN</type>
                <xsl:call-template name="meta"/>
            </relation>
            <xsl:for-each select="dcterms:alternative[text() != '']">
                <xsl:variable name="numTitreAlt" select="position() + 1"/>
                <relation xref="{concat($racineId, '/w/nomen/', $numTitreAlt)}">
                    <xsl:call-template name="meta"/>
                    <type>A_POUR_NOMEN</type>
                </relation>
            </xsl:for-each>
            <!-- ERM comme on ne traite que les élements d'entrée sans subdivision, il peut y avoir des doublons ==> tri sur les relations-->
            <xsl:for-each-group
                select="tef:sujetRameau/child::node()[tef:elementdEntree[@autoriteExterne and @autoriteSource = 'Sudoc'][text() != '']]"
                group-by="tef:elementdEntree/@autoriteExterne">
                <xsl:apply-templates select="current-group()[1]" mode="relation"><xsl:with-param name="nnt" select="$nnt"/></xsl:apply-templates>
            </xsl:for-each-group>
            <xsl:for-each
                select="ancestor::mets:mets//tef:thesisAdmin/tef:thesis.degree/tef:thesis.degree.grantor[tef:autoriteExterne[@autoriteSource = 'Sudoc']/text() != '']">
                <xsl:variable name="idref"
                    select="tef:autoriteExterne[@autoriteSource = 'Sudoc'][1]"/>
                <xsl:variable name="idrefURL" select="concat('http://www.idref.fr/', $idref)"/>
                <relation xref="{$idrefURL}">
                    <!--<type>A_POUR_CONTRIBUTEUR_ETABSOUTENANCE</type>-->
                    <type>A_POUR_CONTRIBUTEUR</type>
                    <xsl:call-template name="meta"/>
                    <propriete nom="ROLE">etabSoutenance</propriete>
                </relation>
            </xsl:for-each>
            <!-- ERM : Dans l'échantillon tous les contributeurs ont un lien idref => ils sont tous liés à l'oeuvre
              XPATH de test :   //tef:thesisAdmin/tef:auteur[not(tef:autoriteExterne[@autoriteSource = 'Sudoc'])] | //tef:thesisAdmin/tef:directeurThese[not(tef:autoriteExterne[@autoriteSource = 'Sudoc'])]  | //tef:thesisAdmin/tef:presidentJury[not(tef:autoriteExterne[@autoriteSource = 'Sudoc'])]  | //tef:thesisAdmin/tef:membreJury[not(tef:autoriteExterne[@autoriteSource = 'Sudoc'])]  | //tef:thesisAdmin/tef:rapporteur[not(tef:autoriteExterne[@autoriteSource = 'Sudoc'])]  | //tef:thesisAdmin/tef:ecoleDoctorale[not(tef:autoriteExterne[@autoriteSource = 'Sudoc'])]  | //tef:thesisAdmin/tef:partenaireRecherche[not(tef:autoriteExterne[@autoriteSource = 'Sudoc'])] 
             
            Si ce n'était pas le cas, il aurait fallu faire une relation de MENTION depuis les manifestations :
            exemple :
            double balisage pour génerer des noeuds contexte et/ou des relation de relation
           <Entite id="http://www.abes.fr/PPN_223690201/m/elec">
           <type lrm="MANIFESTATION">MANIFESTATION</type>
           ....
           <relation>
                <type>MENTIONNE</type>
                <Entite id="http://www.abes.fr/PPN_223690201/m/elec/contexte/1">
                      <type lrm="CONTEXTE">CONTEXTE</type>
                                            <type>CONTRIBUTION</type>
                     <propriete nom="ROLE">auteur</propriete>
                    <propriete nom="RANG">1</propriete>
                    <propriete nom="RANG_PAR_ROLE">aut1</propriete>
                    <relation xref="http://www.abes.fr/PPN_223690201/m/elec/contexte/1/contrib/nomen">
                        <type>A_POUR_MENTION_DE_CONTRIBUTEUR</type>
                    </relation>
                    <relation2 xref="http://www.abes.fr/PPN_223690201/m/elec/contexte/1/aff/nomen">
                        <type>A_POUR_MENTION_D_AFFILIATION</type>
                    </relation2>
                </Entite>
            </relation>-->
            <!--ERM : Un même idref peut avoir différents rôles pour la thèse (directeur et membre du jury) 
              =>!!!NON pour les relations concernées : il faut les typer pour ne pas doublonner ==>  A_POUR_CONTRIB_ROLE !!! NON
            ======> autre solution propriété mutlivaluée pour neo4j
            => pour les entités concernées : il faut un tri pour ne générer qu'une fois l'entite id=idref 
            -->
            <xsl:for-each
                select="ancestor::mets:mets//tef:thesisAdmin/tef:auteur[tef:autoriteExterne[@autoriteSource = 'Sudoc']/text() != ''] | ancestor::mets:mets//tef:thesisAdmin/tef:directeurThese[tef:autoriteExterne[@autoriteSource = 'Sudoc']/text() != ''] | ancestor::mets:mets//tef:thesisAdmin/tef:presidentJury[tef:autoriteExterne[@autoriteSource = 'Sudoc']/text() != ''] | ancestor::mets:mets//tef:thesisAdmin/tef:membreJury[tef:autoriteExterne[@autoriteSource = 'Sudoc']/text() != ''] | ancestor::mets:mets//tef:thesisAdmin/tef:rapporteur[tef:autoriteExterne[@autoriteSource = 'Sudoc']/text() != ''] | ancestor::mets:mets//tef:thesisAdmin/tef:ecoleDoctorale[tef:autoriteExterne[@autoriteSource = 'Sudoc']/text() != ''] | ancestor::mets:mets//tef:thesisAdmin/tef:partenaireRecherche[tef:autoriteExterne[@autoriteSource = 'Sudoc']/text() != '']">
                <xsl:variable name="idref"
                    select="tef:autoriteExterne[@autoriteSource = 'Sudoc'][1]"/>
                <xsl:variable name="idrefURL" select="concat('http://www.idref.fr/', $idref)"/>
                <xsl:variable name="role">
                    <xsl:value-of select="substring-after(name(self::node()), 'tef:')"/>
                </xsl:variable>
                <relation xref="{$idrefURL}">
                    <type>A_POUR_CONTRIBUTEUR</type>
                    <!-- <xsl:value-of select="concat('A_POUR_CONTRIBUTEUR_', upper-case($role))"/>-->
                    <xsl:call-template name="meta"/>
                    <propriete nom="ROLE">
                        <xsl:value-of select="substring-after(name(self::node()), 'tef:')"/>
                    </propriete>
                </relation>
            </xsl:for-each>
            <xsl:for-each
                select="ancestor::mets:mets//mets:structMap/mets:div/mets:div[@TYPE = 'VERSION_INCOMPLETE' or @TYPE = 'VERSION_COMPLETE']">
                <relation xref="{$racineId}/e/{position()}">
                    <type>A_POUR_EXPRESSION</type>
                    <xsl:call-template name="meta"/>
                </relation>
            </xsl:for-each>
        </Entite>
        <!-- Nomen Titre-->
        <!-- nb: dc:title est obligatoire et non répétable-->
        <xsl:for-each select="dc:title">
            <Entite id="{concat($racineId, '/w/nomen/1')}">
                <type lrm="NOMEN">NOMEN</type>
                <type>TITRE</type>
                <xsl:call-template name="meta">
                    <xsl:with-param name="nnt" select="$nnt"/>
                    <xsl:with-param name="id" select="$nnt"/>
                </xsl:call-template>
                <propriete nom="TYPE_ACCES">paa</propriete>
                <propriete nom="VALEUR">
                    <xsl:value-of select="normalize-space(.)"/>
                </propriete>
                <propriete nom="ALPHABET">latin</propriete>
                <propriete nom="LANGUE">
                    <xsl:call-template name="langue">
                        <xsl:with-param name="langue" select="@xml:lang"/>
                    </xsl:call-template>
                </propriete>
            </Entite>
        </xsl:for-each>
        <!-- Nomen Titre(s) Altenatif(s)-->
        <xsl:for-each select="dcterms:alternative">
            <xsl:variable name="numTitreAlt" select="position() + 1"/>
            <Entite id="{concat($racineId, '/w/nomen/', $numTitreAlt)}">
                <type lrm="NOMEN">NOMEN</type>
                <type>TITRE</type>
                <xsl:call-template name="meta">
                    <xsl:with-param name="nnt" select="$nnt"/>
                    <xsl:with-param name="id" select="$nnt"/>
                </xsl:call-template>
                <propriete nom="TYPE_ACCES">vpa</propriete>
                <propriete nom="VALEUR">
                    <xsl:value-of select="normalize-space(.)"/>
                </propriete>
                <propriete nom="ALPHABET">latin</propriete>
                <propriete nom="LANGUE">
                    <xsl:call-template name="langue">
                        <xsl:with-param name="langue" select="@xml:lang"/>
                    </xsl:call-template>
                </propriete>
            </Entite>
        </xsl:for-each>
        <!-- Sujet Rameau -->
        <!-- ERM comme on ne traite que les élements d'entrée sans subdivision, il peut y avoir des doublons ==> tri sur les entites-->
        <xsl:for-each-group
            select="tef:sujetRameau/child::node()[tef:elementdEntree[@autoriteExterne and @autoriteSource = 'Sudoc'][text() != '']]"
            group-by="tef:elementdEntree/@autoriteExterne">
            <xsl:apply-templates select="current-group()[1]" mode="entite">
                <xsl:with-param name="nnt" select="$nnt"/>
            </xsl:apply-templates>
        </xsl:for-each-group>
        <!--Contributeur : établissement de soutenance-->
        <xsl:for-each
            select="ancestor::mets:mets//tef:thesisAdmin/tef:thesis.degree/tef:thesis.degree.grantor[tef:autoriteExterne[@autoriteSource = 'Sudoc']/text() != '']">
            <xsl:variable name="idref" select="tef:autoriteExterne[@autoriteSource = 'Sudoc'][1]"/>
            <xsl:variable name="idrefURL" select="concat('http://www.idref.fr/', $idref)"/>
            <Entite id="{$idrefURL}">
                <type lrm="AGENT">AGENT</type>
                <type>COLLECTIVITE</type>
                <xsl:call-template name="meta">
                    <xsl:with-param name="nnt" select="$nnt"/>
                    <xsl:with-param name="id" select="$idref"/>
                </xsl:call-template>
                <relation xref="{concat($idrefURL,'/nomen')}">
                    <type>A_POUR_NOMEN</type>
                    <xsl:call-template name="meta"/>
                </relation>
            </Entite>
            <Entite id="{concat($idrefURL,'/nomen')}">
                <type lrm="NOMEN">NOMEN</type>
                <type>COLLECTIVITE</type>
                <xsl:call-template name="meta">
                    <xsl:with-param name="nnt" select="$nnt"/>
                    <xsl:with-param name="id" select="$idref"/>
                </xsl:call-template>
                <propriete nom="TYPE_ACCES">paa</propriete>
            </Entite>
        </xsl:for-each>
        <!--Autres contributeurs-->
        <!--ERM : Un même idref peut avoir différents rôles pour la thèse (directeur et membre du jury) 
            =>!!!NON pour les relations concernées : il faut les typer pour ne pas doublonner ==>  A_POUR_CONTRIB_ROLE !!! NON
            ======> autre solution propriété mutlivaluée pour neo4j
            => pour les entités concernées : il faut un tri pour ne générer qu'une fois l'entite id=idref 
            -->
        <xsl:for-each-group
            select="ancestor::mets:mets//tef:thesisAdmin/tef:auteur[tef:autoriteExterne[@autoriteSource = 'Sudoc']/text() != ''] | ancestor::mets:mets//tef:thesisAdmin/tef:directeurThese[tef:autoriteExterne[@autoriteSource = 'Sudoc']/text() != ''] | ancestor::mets:mets//tef:thesisAdmin/tef:presidentJury[tef:autoriteExterne[@autoriteSource = 'Sudoc']/text() != ''] | ancestor::mets:mets//tef:thesisAdmin/tef:membreJury[tef:autoriteExterne[@autoriteSource = 'Sudoc']/text() != ''] | ancestor::mets:mets//tef:thesisAdmin/tef:rapporteur[tef:autoriteExterne[@autoriteSource = 'Sudoc']/text() != ''] | ancestor::mets:mets//tef:thesisAdmin/tef:ecoleDoctorale[tef:autoriteExterne[@autoriteSource = 'Sudoc']/text() != ''] | ancestor::mets:mets//tef:thesisAdmin/tef:partenaireRecherche[tef:autoriteExterne[@autoriteSource = 'Sudoc']/text() != '']"
            group-by="tef:autoriteExterne[@autoriteSource = 'Sudoc']">
            <xsl:apply-templates select="current-group()[1]">
                <xsl:with-param name="nnt" select="$nnt"/>
            </xsl:apply-templates>
        </xsl:for-each-group>
        <!--Expressions-->
        <xsl:for-each
            select="ancestor::mets:mets//mets:structMap/mets:div/mets:div[@TYPE = 'VERSION_INCOMPLETE' or @TYPE = 'VERSION_COMPLETE']">
            <xsl:variable name="idExpression">
                <xsl:value-of select="concat($racineId, '/e/', position())"/>
            </xsl:variable>
            <xsl:variable name="idTEF">
                <xsl:value-of select="@DMDID"/>
            </xsl:variable>
            <Entite id="{$idExpression}">
                <type lrm="EXPRESSION">EXPRESSION</type>
                <type>MONOGRAPHIE</type>
                <type>THESE</type>
                <type>
                    <xsl:choose>
                        <xsl:when test="@TYPE = 'VERSION_COMPLETE'">VERSION_COMPLETE</xsl:when>
                        <xsl:otherwise>VERSION_INCOMPLETE</xsl:otherwise>
                    </xsl:choose>
                </type>
                <xsl:call-template name="meta">
                    <xsl:with-param name="nnt" select="$nnt"/>
                    <xsl:with-param name="id" select="$nnt"/>
                </xsl:call-template>
                <propriete nom="LANGUE">
                    <xsl:value-of select="$langue"/>
                </propriete>
                <!--ERM : Dans l'échantillon : il n'y que le cas avec tef:noteVersion, d'autres conctructions sont possibles : http://www.abes.fr/abes/documents/tef/recommandation/intro_desc_version.html-->
                <xsl:for-each
                    select="ancestor::mets:mets//mets:dmdSec[@ID = $idTEF]//tef:manque/tef:noteVersion[text() != '']">
                    <propriete nom="RESSOURCE_MANQUANTE">
                        <xsl:value-of select="normalize-space(.)"/>
                    </propriete>
                </xsl:for-each>
                <xsl:for-each select="mets:div[@TYPE = 'EDITION']">
                    <relation xref="{$idExpression}/m/{position()}">
                        <type>A_POUR_MANIFESTATION</type>
                        <xsl:call-template name="meta"/>
                    </relation>
                </xsl:for-each>
            </Entite>
        </xsl:for-each>
        <!--Manifestations-->
        <xsl:for-each
            select="ancestor::mets:mets//mets:structMap/mets:div/mets:div[@TYPE = 'VERSION_INCOMPLETE' or @TYPE = 'VERSION_COMPLETE']">
            <xsl:variable name="idExpression">
                <xsl:value-of select="concat($racineId, '/e/', position())"/>
            </xsl:variable>
            <xsl:for-each select="mets:div[@TYPE = 'EDITION']">
                <xsl:variable name="idTEF">
                    <xsl:value-of select="@DMDID"/>
                </xsl:variable>
                <Entite id="{$idExpression}/m/{position()}">
                    <type lrm="MANIFESTATION">MANIFESTATION</type>
                    <type>MONOGRAPHIE</type>
                    <type>THESE</type>
                    <type>ELECTRONIQUE</type>
                    <xsl:call-template name="meta">
                        <xsl:with-param name="nnt" select="$nnt"/>
                        <xsl:with-param name="id" select="$nnt"/>
                    </xsl:call-template>
                    <xsl:for-each select="ancestor::mets:mets//mets:dmdSec[@ID = $idTEF]">
                        <xsl:if
                            test="mets:mdWrap/mets:xmlData/tef:edition/dcterms:medium[text() != '']">
                            <propriete nom="FORMAT">
                                <xsl:value-of
                                    select="normalize-space(mets:mdWrap/mets:xmlData/tef:edition/dcterms:medium)"
                                />
                            </propriete>
                        </xsl:if>
                        <xsl:for-each
                            select="mets:mdWrap/mets:xmlData/tef:edition/dc:identifier[@xsi:type = 'dcterms:URI'][text() != '']">
                            <propriete nom="URI">
                                <xsl:value-of select="normalize-space(.)"/>
                            </propriete>
                        </xsl:for-each>
                    </xsl:for-each>
                </Entite>
            </xsl:for-each>
        </xsl:for-each>
    </xsl:template>
    <xsl:template match="tef:sujetRameau/child::node()" mode="relation">
        <xsl:param name="nnt"/>
        <relation xref="{concat('http://www.idref.fr/', tef:elementdEntree/@autoriteExterne)}">
            <type>A_POUR_SUJET</type>
            <xsl:call-template name="meta"/>
            <propriete nom="REFERENTIEL">rameau</propriete>
        </relation>
    </xsl:template>
    <xsl:template match="tef:sujetRameau/child::node()" mode="entite">
        <xsl:param name="nnt"/>
        <xsl:variable name="idRameau" select="tef:elementdEntree/@autoriteExterne"/>
        <xsl:variable name="idRameauURL" select="concat('http://www.idref.fr/', $idRameau)"/>
        <Entite id="{$idRameauURL}">
            <xsl:call-template name="rameau">
                <xsl:with-param name="typeVedette"
                    select="substring-after(name(self::node()), 'tef:')"/>
            </xsl:call-template>
            <xsl:call-template name="meta">
                <xsl:with-param name="nnt" select="$nnt"/>
                <xsl:with-param name="id" select="$idRameau"/>
            </xsl:call-template>
            <propriete nom="REFERENTIEL">rameau</propriete>
            <relation xref="{concat($idRameauURL,'/nomen')}">
                <type>A_POUR_NOMEN</type>
                <xsl:call-template name="meta"/>
            </relation>
        </Entite>
        <Entite id="{concat($idRameauURL, '/nomen')}">
            <type lrm="NOMEN">NOMEN</type>
            <xsl:call-template name="rameauNomen">
                <xsl:with-param name="typeVedette"
                    select="substring-after(name(self::node()), 'tef:')"/>
            </xsl:call-template>
            <xsl:call-template name="meta">
                <xsl:with-param name="nnt" select="$nnt"/>
                <xsl:with-param name="id" select="$idRameau"/>
            </xsl:call-template>
            <propriete nom="TYPE_ACCES">paa</propriete>
            <propriete nom="VALEUR">
                <xsl:value-of select="normalize-space(tef:elementdEntree)"/>
            </propriete>
            <propriete nom="ALPHABET">latin</propriete>
            <propriete nom="LANGUE">français</propriete>
        </Entite>
    </xsl:template>
    <xsl:template
        match="tef:auteur | tef:directeurThese | tef:presidentJury | tef:membreJury | tef:rapporteur | tef:ecoleDoctorale | tef:partenaireRecherche">
        <xsl:param name="nnt"/>
        <xsl:variable name="idref" select="tef:autoriteExterne[@autoriteSource = 'Sudoc'][1]"/>
        <xsl:variable name="idrefURL" select="concat('http://www.idref.fr/', $idref)"/>
        <xsl:choose>
            <xsl:when test="self::tef:ecoleDoctorale | self::tef:partenaireRecherche">
                <Entite id="{$idrefURL}">
                    <type lrm="AGENT">AGENT</type>
                    <type>COLLECTIVITE</type>
                    <xsl:call-template name="meta">
                        <xsl:with-param name="nnt" select="$nnt"/>
                        <xsl:with-param name="id" select="$idref"/>
                    </xsl:call-template>
                    <relation xref="{concat($idrefURL,'/nomen')}">
                        <type>A_POUR_NOMEN</type>
                        <xsl:call-template name="meta"/>
                    </relation>
                </Entite>
                <Entite id="{concat($idrefURL,'/nomen')}">
                    <xsl:call-template name="nomen">
                        <xsl:with-param name="nnt" select="$nnt"/>
                        <xsl:with-param name="idref" select="$idref"/>
                        <xsl:with-param name="type" select="'COLLECTIVITE'"/>
                        <xsl:with-param name="typeAcces" select="'paa'"/>
                    </xsl:call-template>
                </Entite>
            </xsl:when>
            <xsl:otherwise>
                <Entite id="{$idrefURL}">
                    <type lrm="AGENT">AGENT</type>
                    <type>PERSONNE</type>
                    <xsl:call-template name="meta">
                        <xsl:with-param name="nnt" select="$nnt"/>
                        <xsl:with-param name="id" select="$idref"/>
                    </xsl:call-template>
                    <relation xref="{concat($idrefURL,'/nomen')}">
                        <type>A_POUR_NOMEN</type>
                        <xsl:call-template name="meta"/>
                    </relation>
                </Entite>
                <Entite id="{concat($idrefURL,'/nomen')}">
                    <xsl:call-template name="nomen">
                        <xsl:with-param name="nnt" select="$nnt"/>
                        <xsl:with-param name="idref" select="$idref"/>
                        <xsl:with-param name="type" select="'PERSONNE'"/>
                        <xsl:with-param name="typeAcces" select="'paa'"/>
                    </xsl:call-template>
                </Entite>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template name="lang">
        <xsl:param name="lang"/>
        <xsl:choose>
            <xsl:when test="$lang = 'fr'">fre</xsl:when>
            <xsl:when test="$lang = 'en'">eng</xsl:when>
            <xsl:when test="$lang = 'de'">ger</xsl:when>
            <xsl:when test="$lang = 'es'">spa</xsl:when>
        </xsl:choose>
    </xsl:template>
    <xsl:template name="langue">
        <xsl:param name="langue"/>
        <xsl:choose>
            <xsl:when test="$langue = 'fr'">français</xsl:when>
            <xsl:when test="$langue = 'en'">anglais</xsl:when>
            <xsl:when test="$langue = 'de'">allemand</xsl:when>
            <xsl:when test="$langue = 'es'">espagnol</xsl:when>
        </xsl:choose>
    </xsl:template>
    <xsl:template name="rameau">
        <xsl:param name="typeVedette"/>
        <xsl:choose>
            <xsl:when test="$typeVedette = 'RameauPersonne'">
                <type lrm="AGENT">AGENT</type>
                <type>PERSONNE</type>
            </xsl:when>
            <xsl:when test="$typeVedette = 'vedetteRameauCollectivite'">
                <type lrm="AGENT">AGENT</type>
                <type>COLLECTIVITE</type>
            </xsl:when>
            <xsl:when test="$typeVedette = 'vedetteRameauFamille'">
                <type lrm="AGENT">AGENT</type>
                <type>PERSONNE</type>
            </xsl:when>
            <xsl:when test="$typeVedette = 'vedetteRameauAuteurTitre'">
                <type lrm="OEUVRE">OEUVRE</type>
            </xsl:when>
            <xsl:when test="$typeVedette = 'vedetteRameauTitre'">
                <type lrm="OEUVRE">OEUVRE</type>
            </xsl:when>
            <xsl:when test="$typeVedette = 'vedetteRameauNomCommun'">
                <type lrm="CONCEPT">CONCEPT</type>
            </xsl:when>
            <xsl:when test="$typeVedette = 'vedetteRameauNomGeographique'">
                <type lrm="LIEU">LIEU</type>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    <xsl:template name="rameauNomen">
        <xsl:param name="typeVedette"/>
        <xsl:choose>
            <xsl:when test="$typeVedette = 'vedetteRameauPersonne'">
                <type>PERSONNE</type>
            </xsl:when>
            <xsl:when test="$typeVedette = 'vedetteRameauCollectivite'">
                <type>COLLECTIVITE</type>
            </xsl:when>
            <xsl:when test="$typeVedette = 'vedetteRameauFamille'">
                <type>PERSONNE</type>
            </xsl:when>
            <xsl:when test="$typeVedette = 'vedetteRameauAuteurTitre'">
                <type>TITRE</type>
            </xsl:when>
            <xsl:when test="$typeVedette = 'vedetteRameauTitre'">
                <type>TITRE</type>
            </xsl:when>
            <xsl:when test="$typeVedette = 'vedetteRameauNomCommun'">
                <type>NOM_COMMUN</type>
            </xsl:when>
            <xsl:when test="$typeVedette = 'vedetteRameauNomGeographique'">
                <type>NOM_LIEU</type>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    <xsl:template name="nomen">
        <xsl:param name="idref"/>
        <xsl:param name="type"/>
        <xsl:param name="typeAcces"/>
        <xsl:param name="nnt"/>
        <type lrm="NOMEN">NOMEN</type>
        <type>
            <xsl:value-of select="$type"/>
        </type>
        <xsl:call-template name="meta">
            <xsl:with-param name="nnt" select="$nnt"/>
            <xsl:with-param name="id" select="$idref"/>
        </xsl:call-template>
        <propriete nom="TYPE_ACCES">
            <xsl:value-of select="$typeAcces"/>
        </propriete>
        <propriete nom="VALEUR">
            <xsl:value-of select="normalize-space(tef:nom)"/>
            <xsl:if test="tef:prenom != ''">
                <xsl:value-of select="concat(', ', normalize-space(tef:prenom))"/>
            </xsl:if>
        </propriete>
        <xsl:if test="$type = 'PERSONNE'">
            <propriete nom="NOM">
                <xsl:value-of select="normalize-space(tef:nom)"/>
            </propriete>
            <xsl:if test="tef:prenom != ''">
                <propriete nom="PRENOM">
                    <xsl:value-of select="normalize-space(tef:prenom)"/>
                </propriete>
            </xsl:if>
        </xsl:if>
        <propriete nom="ALPHABET">latin</propriete>
    </xsl:template>
    <xsl:template name="meta">
        <xsl:param name="nnt" />
        <xsl:param name="id"/>
        <xsl:if test="$id != ''">
            <propriete nom="ID_SOURCE">
                <xsl:value-of select="$id"/>
            </propriete>
            <xsl:if test="$id != $nnt">
            <propriete nom="CITE_DANS">
                <xsl:value-of select="$nnt"/>
            </propriete></xsl:if>
        </xsl:if>
        <propriete nom="META_SOURCE">TEF</propriete>
        <propriete nom="META_ACTEUR">XSL Pivot</propriete>
    </xsl:template>
</xsl:stylesheet>
