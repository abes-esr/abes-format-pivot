<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
    xmlns:skos="http://www.w3.org/2004/02/skos/core#"
    xmlns:rdaw="http://rdaregistry.info/Elements/w/"
    xmlns:rdac="http://rdaregistry.info/Elements/c/" xmlns:hub="http://hub.abes.fr/namespace/"
    xmlns:dcterms="http://purl.org/dc/terms/"
    xmlns:isbd="http://iflastandards.info/ns/isbd/elements/"
    xmlns:bibo="http://purl.org/ontology/bibo/" xmlns:foaf="http://xmlns.com/foaf/0.1/"
    xmlns:vivo="http://vivoweb.org/ontology/core#" xmlns:sudoc21="http://www.abes.fr/namespace/"
    exclude-result-prefixes="xs rdf rdfs skos rdaw rdac hub dcterms isbd bibo foaf vivo"
    version="2.0">
    <xsl:output encoding="UTF-8" method="xml" indent="yes"/>
    <xsl:strip-space elements="*"/>
    <xsl:template match="/rdf">
        <CollWemi>
            <xsl:apply-templates
                select="Description[not(type/@resource = 'http://vivoweb.org/ontology/core#Authorship')]"
            />
        </CollWemi>
    </xsl:template>
    <xsl:template
        match="Description[not(type/@resource = 'http://vivoweb.org/ontology/core#Authorship')]">
        <xsl:choose>
            <xsl:when test="type/@resource = 'http://purl.org/ontology/bibo/Volume'">
                <xsl:variable name="racineId" select="@about"/>
                <Entite id="{concat(@about, '/w')}">
                    <type lrm="OEUVRE_AGREGATIVE">OEUVRE_AGREGATIVE</type>
                    <type>PARTIE_COMPOSANTE</type>
                    <type>VOLUME</type>
                    <relation>
                        <xsl:attribute name="xref" select="concat(@about, '/m/print')"/>
                        <type>A_POUR_MANIFESTATION_SS_E</type>
                        <xsl:call-template name="meta"/>
                    </relation>
                    <relation>
                        <xsl:attribute name="xref" select="concat(@about, '/m/web')"/>
                        <type>A_POUR_MANIFESTATION_SS_E</type>
                        <xsl:call-template name="meta"/>
                    </relation>
                    <xsl:call-template name="meta">
                        <xsl:with-param name="id_source" select="$racineId"/>
                    </xsl:call-template>
                </Entite>
                <xsl:call-template name="volume">
                    <xsl:with-param name="racineId" select="concat(@about, '/m/print')"/>
                    <xsl:with-param name="id_source" select="$racineId"/>
                </xsl:call-template>
                <xsl:call-template name="volume">
                    <xsl:with-param name="racineId" select="concat(@about, '/m/web')"/>
                    <xsl:with-param name="id_source" select="$racineId"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when
                test="type/@resource = 'http://purl.org/ontology/bibo/Issue' and type/@resource = 'http://rdaregistry.info/Elements/c/C10001'">
                <xsl:variable name="racineId" select="@about"/>
                <Entite id="{$racineId}">
                    <type lrm="OEUVRE_AGREGATIVE">OEUVRE_AGREGATIVE</type>
                    <type>PARTIE_COMPOSANTE</type>
                    <type>NUMERO</type>
                    <xsl:for-each select="P10072/@resource">
                        <relation>
                            <xsl:attribute name="xref" select="."/>
                            <type>A_POUR_MANIFESTATION_SS_E</type>
                            <xsl:call-template name="meta"/>
                        </relation>
                    </xsl:for-each>
                    <xsl:call-template name="meta">
                        <xsl:with-param name="id_source" select="$racineId"/>
                    </xsl:call-template>
                </Entite>
            </xsl:when>
            <xsl:otherwise>
                <!-- Entités tous types sauf expressions et nomens et volumes, et on omet l'authorship -->
                <xsl:variable name="racineId" select="@about"/>
                <Entite id="{$racineId}">
                    <!-- BLOC TYPES ENTITES -->
                    <xsl:comment>BLOC TYPES ENTITES</xsl:comment>
                    <xsl:call-template name="types_relations">
                        <xsl:with-param name="mode" select="'type'"/>
                        <xsl:with-param name="racineId" select="$racineId"/>
                        <xsl:with-param name="id_source" select="$racineId"/>
                    </xsl:call-template>
                    <!-- Propriétés de l'entité -->
                    <!-- Propriétés des oeuvres -->
                    <!--<xsl:choose>
                <xsl:when test="language[text()!='']">-->
                    <xsl:for-each select="language">
                        <propriete nom="LANGUE">
                            <xsl:call-template name="codeLangue">
                                <xsl:with-param name="code" select="."/>
                            </xsl:call-template>
                        </propriete>
                    </xsl:for-each>
                    <xsl:for-each select="dateSubmitted[text() != '']">
                        <propriete nom="DATE_SOUMISSION">
                            <xsl:value-of select="normalize-space()"/>
                        </propriete>
                    </xsl:for-each>
                    <xsl:for-each select="dateAccepted[text() != '']">
                        <propriete nom="DATE_ACCEPTATION">
                            <xsl:value-of select="normalize-space()"/>
                        </propriete>
                    </xsl:for-each>
                    <xsl:for-each select="ddc[text() != '']">
                        <propriete nom="INDICE_DEWEY">
                            <xsl:value-of select="normalize-space(text())"/>
                        </propriete>
                    </xsl:for-each>
                    <xsl:for-each select="abstract[text() != '']">

                        <propriete nom="RESUME">
                            <xsl:if test="@lang">
                                <xsl:attribute name="lang">
                                    <xsl:call-template name="codeLangue">
                                        <xsl:with-param name="code" select="@lang[. != '']"/>
                                    </xsl:call-template>
                                </xsl:attribute>
                            </xsl:if>
                            <xsl:value-of select="normalize-space(text())"/>
                        </propriete>
                    </xsl:for-each>
                    <!-- Propriétés des manifestations-->
                    <!-- rapatriées depuis les issues "/w" -->
                    <xsl:if test="type/@resource = 'http://purl.org/ontology/bibo/Issue'">
                        <xsl:for-each select="//Description[@about = .]">
                            <xsl:for-each select="issue[text() != '']">
                                <xsl:value-of select="normalize-space(.)"/>
                            </xsl:for-each>
                        </xsl:for-each>
                    </xsl:if>
                    <xsl:for-each select="volume[text() != '']">
                        <propriete nom="NUM_VOL">
                            <xsl:value-of select="."/>
                        </propriete>
                    </xsl:for-each>
                    <xsl:for-each select="publisher-id[text() != ''] | sercode[text() != '']">
                        <propriete nom="ID_EDITEUR">
                            <xsl:value-of select="."/>
                        </propriete>
                    </xsl:for-each>
                    <xsl:for-each select="edition[text() != '']">
                        <propriete nom="MENTION_EDITION">
                            <xsl:value-of select="."/>
                        </propriete>
                    </xsl:for-each>
                    <xsl:for-each select="pageStart[text() != '']">
                        <propriete nom="PAGE_DEBUT">
                            <xsl:value-of select="."/>
                        </propriete>
                    </xsl:for-each>
                    <xsl:for-each select="pageEnd[text() != '']">
                        <propriete nom="PAGE_FIN">
                            <xsl:value-of select="."/>
                        </propriete>
                    </xsl:for-each>
                    <xsl:for-each select="numPages[text() != '']">
                        <propriete nom="NB_PAGES">
                            <xsl:value-of select="."/>
                        </propriete>
                    </xsl:for-each>
                    <xsl:for-each select="issn[text() != '']">
                        <propriete nom="ISSN">
                            <xsl:value-of select="."/>
                        </propriete>
                    </xsl:for-each>
                    <xsl:for-each select="isbn[text() != '']">
                        <xsl:choose>
                            <xsl:when
                                test="string-length(replace(normalize-space(.), '[^0-9]', '')) = 13">
                                <propriete nom="ISBN13">
                                    <xsl:value-of select="normalize-space(.)"/>
                                </propriete>
                            </xsl:when>
                            <xsl:when
                                test="string-length(replace(normalize-space(.), '[^0-9]', '')) = 10">
                                <propriete nom="ISBN10">
                                    <xsl:value-of select="normalize-space(.)"/>
                                </propriete>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:for-each>
                    <xsl:for-each select="isbn13[text() != '']">
                        <propriete nom="ISBN13">
                            <xsl:value-of select="normalize-space(.)"/>
                        </propriete>
                    </xsl:for-each>
                    <xsl:for-each select="isbn10[text() != '']">
                        <propriete nom="ISBN10">
                            <xsl:value-of select="normalize-space(.)"/>
                        </propriete>
                    </xsl:for-each>
                    <xsl:for-each select="format[text() != '']">
                        <propriete nom="FORMAT">
                            <xsl:value-of select="normalize-space(.)"/>
                        </propriete>
                    </xsl:for-each>
                    <xsl:if test="issued[text() != ''][1]">
                        <propriete nom="ANNEE_PUBLICATION">
                            <xsl:choose>
                                <xsl:when
                                    test="issued/@datatype = 'http://www.w3.org/2001/XMLSchema#gYear'">
                                    <xsl:value-of select="issued"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="xs:gYear(max(issued/xs:date(.)))"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </propriete>
                    </xsl:if>
                    <!-- </xsl:when>-->
                    <!-- extrapoler la langue du titre à celle du document ? Dans l'écahntillon pas sûr qu'on ait des language. De toute façon l'info est récupérée dans le nomen
                    <xsl:when test="title[@xml:lang!='']">
                    <xsl:for-each
                        select="title[@xml:lang]">
                        <propriete nom="LANGUE">
                            <xsl:call-template name="codeLangue">
                                <xsl:with-param name="code" select="."/>
                            </xsl:call-template>
                        </propriete>
                    </xsl:for-each>-->
                    <!--</xsl:when>-->
                    <!--</xsl:choose>-->
                    <!-- Propriétés des personnes -->
                    <xsl:for-each select="mbox[text() != '']">
                        <propriete nom="EMAIL">
                            <xsl:value-of select="normalize-space(.)"/>
                        </propriete>
                    </xsl:for-each>
                    <!-- alignements -->
                    <xsl:for-each select="sameAs/@resource[. != '']">
                        <propriete nom="IDENTIFIE_A">
                            <xsl:value-of select="normalize-space(.)"/>
                        </propriete>
                    </xsl:for-each>
                    <!-- Propriétés des collectivités (affiliations) -->
                    <xsl:for-each select="country-name[text() != '']">
                        <propriete nom="PAYS">
                            <xsl:value-of select="normalize-space(.)"/>
                        </propriete>
                    </xsl:for-each>
                    <xsl:for-each select="locality[text() != '']">
                        <propriete nom="VILLE">
                            <xsl:value-of select="normalize-space(.)"/>
                        </propriete>
                    </xsl:for-each>
                    <!-- Relations de l'entité -->
                    <!-- Relations nomens. S'il y a un sous-titre il devient une propriété du nomen -->
                    <xsl:for-each
                        select="title[text() != ''] | shortTitle[text() != ''] | alternative[text() != ''] | prefLabel[text() != ''] | familyName[text() != ''] | organization-name[text() != ''] | organization-unit[text() != ''] | affiliationContent[text() != ''] | name[parent::type/@resource = 'http://xmlns.com/foaf/0.1/Organization'][text() != '']">
                        <relation>
                            <xsl:attribute name="xref"
                                select="concat($racineId, '/nomen/', position())"/>
                            <type>A_POUR_NOMEN</type>
                            <!-- - - -->
                            <xsl:call-template name="meta"/>
                        </relation>
                    </xsl:for-each>
                    <!-- relations LRM et d'appartenance FAIT_PARTIE_DE / EST AGREGE_DANS -->
                    <xsl:call-template name="types_relations">
                        <xsl:with-param name="mode" select="'relations'"/>
                        <xsl:with-param name="racineId" select="$racineId"/>
                        <xsl:with-param name="id_source" select="$racineId"/>
                    </xsl:call-template>

                    <xsl:choose>
                        <!-- Contributions oeuvres -->
                        <xsl:when
                            test="type/@resource = 'http://rdaregistry.info/Elements/c/C10001'">
                            <xsl:variable name="roles">aut - edt - cmp</xsl:variable>
                            <xsl:for-each select="relatedBy/@resource[. != '']">
                                <xsl:comment>--- relation contributeur niveau Oeuvre --- <xsl:value-of select="."/></xsl:comment>
                                <xsl:variable name="uriAuthorship" select="."/>
                                <xsl:for-each
                                    select="/rdf/Description[@about = $uriAuthorship and relates[@resource[. != '']] and contains($roles, substring-after(hasRole/@resource, 'http://id.loc.gov/vocabulary/relators/'))]">
                                    <relation>
                                        <xsl:attribute name="xref">
                                            <xsl:value-of select="relates/@resource[. != '']"/>
                                        </xsl:attribute>
                                        <type>A_POUR_CONTRIBUTEUR</type>
                                        <xsl:for-each select="hasRole[@resource != '']">
                                            <propriete nom="ROLE">
                                                <xsl:call-template name="role">
                                                  <xsl:with-param name="codefct"
                                                  select="substring-after(@resource, 'http://id.loc.gov/vocabulary/relators/')"
                                                  />
                                                </xsl:call-template>
                                            </propriete>
                                        </xsl:for-each>
                                        <xsl:for-each select="rank[text() != '']">
                                            <propriete nom="RANG">
                                                <xsl:value-of select="normalize-space(.)"/>
                                            </propriete>
                                        </xsl:for-each>
                                        <xsl:for-each select="rankByRole[text() != '']">
                                            <propriete nom="RANG_PAR_ROLE">
                                                <xsl:value-of select="normalize-space(.)"/>
                                            </propriete>
                                        </xsl:for-each>
                                        <!-- On ne garde pas l'Authorship, même si en sortie csv, elle réapparaitra comme Contribution... -->
                                        <xsl:for-each
                                            select="hasAuthorshipAffiliation[@resource != '']">
                                            <relation>
                                                <xsl:attribute name="xref">
                                                  <xsl:value-of select="normalize-space(@resource)"
                                                  />
                                                </xsl:attribute>
                                                <type>A_POUR_AFFILIATION</type>
                                                <xsl:call-template name="meta">
                                                  <xsl:with-param name="id_source"
                                                  select="parent::node()/@about"/>
                                                </xsl:call-template>
                                            </relation>
                                        </xsl:for-each>
                                        <xsl:call-template name="meta"/>
                                    </relation>
                                </xsl:for-each>
                            </xsl:for-each>
                        </xsl:when>
                        <xsl:when
                            test="type/@resource = 'http://rdaregistry.info/Elements/c/C10007'">
                            <xsl:comment>--- Contributeur niveau Manifestation---</xsl:comment>
                            <xsl:variable name="roles">wpr</xsl:variable>
                            <!-- Relation contributeur dans Authorship : préfacier, ..? -->
                            <xsl:variable name="uriOeuvre">
                                <xsl:value-of
                                    select="concat(substring-before($racineId, '/m/'), '/w')"/>
                            </xsl:variable>
                            <xsl:for-each
                                select="/rdf/Description[@about = $uriOeuvre]/relatedBy/@resource[. != '']">
                                <xsl:variable name="uriAuthorship" select="."/>
                                <xsl:for-each
                                    select="/rdf/Description[@about = $uriAuthorship and relates[@resource[. != '']] and contains($roles, substring-after(hasRole/@resource, 'http://id.loc.gov/vocabulary/relators/'))]">
                                    <relation>
                                        <xsl:attribute name="xref">
                                            <xsl:value-of select="relates/@resource[. != '']"/>
                                        </xsl:attribute>
                                        <type>A_POUR_CONTRIBUTEUR</type>
                                        <xsl:for-each select="hasRole[@resource != '']">
                                            <propriete nom="ROLE">
                                                <xsl:call-template name="role">
                                                  <xsl:with-param name="codefct"
                                                  select="substring-after(@resource, 'http://id.loc.gov/vocabulary/relators/')"
                                                  />
                                                </xsl:call-template>
                                            </propriete>
                                        </xsl:for-each>
                                        <xsl:for-each select="rank[text() != '']">
                                            <propriete nom="RANG">
                                                <xsl:value-of select="normalize-space(.)"/>
                                            </propriete>
                                        </xsl:for-each>
                                        <!-- On ne garde pas l'Authorship, même si en sortie csv, elle réapparaitra comme Contribution... -->
                                        <xsl:for-each
                                            select="hasAuthorshipAffiliation[@resource != '']">
                                            <relation>
                                                <xsl:attribute name="xref">
                                                  <xsl:value-of select="normalize-space(@resource)"
                                                  />
                                                </xsl:attribute>
                                                <type>A_POUR_AFFILIATION</type>
                                                <xsl:call-template name="meta"/>
                                            </relation>
                                        </xsl:for-each>
                                        <xsl:call-template name="meta"/>
                                    </relation>
                                </xsl:for-each>
                            </xsl:for-each>
                            <!-- Spécifique pour l'éditeur commercial : mention ou contribution-->
                            <xsl:for-each select="publisher">
                                <xsl:choose>
                                    <xsl:when test="@resource != ''">
                                        <relation>
                                            <xsl:attribute name="xref">
                                                <xsl:value-of select="@resource"/>
                                            </xsl:attribute>
                                            <type>A_POUR_CONTRIBUTEUR</type>
                                            <propriete nom="ROLE">
                                                <xsl:text>Editeur&#x20;commercial</xsl:text>
                                            </propriete>
                                            <propriete nom="RANG">
                                                <xsl:value-of select="position()"/>
                                            </propriete>
                                            <xsl:call-template name="meta"/>
                                        </relation>
                                    </xsl:when>
                                    <xsl:when test="normalize-space(text()) != ''">
                                        <!-- Cas de l'éditeur commercial sous forme littérale : pour l'imprimé-->
                                        <xsl:variable name="idMention"
                                            select="concat($racineId, '/contexte/', position())"/>
                                        <relation>
                                            <type>A_POUR_MENTION</type>
                                            <xsl:call-template name="meta"/>
                                            <Entite id="{$idMention}">
                                                <type lrm="CONTEXTE">CONTRIBUTION</type>
                                                <xsl:call-template name="meta">
                                                  <xsl:with-param name="id_source"
                                                  select="$racineId"/>
                                                </xsl:call-template>
                                                <propriete nom="ROLE">
                                                  <xsl:text>Editeur&#x20;commercial</xsl:text>
                                                </propriete>
                                                <relation xref="{$idMention}/contrib/nomen">
                                                  <type>A_POUR_MENTION_DE_CONTRIBUTEUR</type>
                                                  <xsl:call-template name="meta">
                                                  <xsl:with-param name="id_source"
                                                  select="parent::Description/@about"/>
                                                  </xsl:call-template>
                                                </relation>
                                            </Entite>
                                        </relation>
                                    </xsl:when>
                                </xsl:choose>
                            </xsl:for-each>
                        </xsl:when>
                    </xsl:choose>
                    <!-- Sujets -->
                    <xsl:for-each select="subject/@resource[. != '']">
                        <relation>
                            <xsl:attribute name="xref" select="."/>
                            <type>A_POUR_SUJET</type>
                            <!-- - - -->
                            <xsl:call-template name="meta"/>
                        </relation>
                    </xsl:for-each>
                    <xsl:for-each select="classification/@resource[. != '']">
                        <relation>
                            <xsl:attribute name="xref" select="."/>
                            <type>A_POUR_CLASSIFICATION</type>
                            <!-- - - -->
                            <xsl:call-template name="meta"/>
                        </relation>
                    </xsl:for-each>
                    <!-- - - -->
                    <xsl:call-template name="meta">
                        <xsl:with-param name="id_source" select="$racineId"/>
                    </xsl:call-template>
                </Entite>
                <!-- Entite expression -->
                <xsl:if test="type[@resource = 'http://rdaregistry.info/Elements/c/C10001']">
                    <xsl:comment>Entite expression</xsl:comment>
                    <xsl:variable name="idExpression"
                        select="concat(substring($racineId, 1, string-length($racineId) - 2), '/e')"/>
                    <Entite>
                        <xsl:attribute name="id" select="$idExpression"/>
                        <!-- type d'expression -->
                        <xsl:call-template name="types_relations">
                            <xsl:with-param name="mode" select="'type'"/>
                            <xsl:with-param name="racineId" select="$idExpression"/>
                            <xsl:with-param name="id_source" select="$racineId"/>
                        </xsl:call-template>
                        <!-- propriétés  de l'expression -->
                        <xsl:for-each select="language">
                            <propriete nom="LANGUE">
                                <xsl:call-template name="codeLangue">
                                    <xsl:with-param name="code" select="."/>
                                </xsl:call-template>
                            </propriete>
                        </xsl:for-each>
                        <!-- date de modification -->
                        <xsl:for-each select="modified[text() != '']">
                            <propriete nom="DATE_MODIFICATION">
                                <xsl:value-of select="normalize-space()"/>
                            </propriete>
                        </xsl:for-each>
                        <!-- relations de l'expression -->
                        <!-- Nomen titre ?-->
                        <!-- Relations LRM  -->
                        <xsl:call-template name="types_relations">
                            <xsl:with-param name="mode" select="'relations'"/>
                            <xsl:with-param name="racineId" select="$idExpression"/>
                            <xsl:with-param name="id_source" select="$racineId"/>
                        </xsl:call-template>
                        <!-- Contributeurs expression-->
                        <xsl:variable name="roles">trl</xsl:variable>
                        <xsl:for-each select="relatedBy/@resource[. != '']">
                            <xsl:comment>--- relation contributeur niveau Expression ---</xsl:comment>
                            <xsl:variable name="uriAuthorship" select="."/>
                            <xsl:for-each
                                select="/rdf/Description[@about = $uriAuthorship and relates[@resource[. != '']] and contains($roles, substring-after(hasRole/@resource, 'http://id.loc.gov/vocabulary/relators/'))]">
                                <relation>
                                    <xsl:attribute name="xref">
                                        <xsl:value-of select="relates/@resource[. != '']"/>
                                    </xsl:attribute>
                                    <type>A_POUR_CONTRIBUTEUR</type>
                                    <xsl:for-each select="hasRole[@resource != '']">
                                        <propriete nom="ROLE">
                                            <xsl:call-template name="role">
                                                <xsl:with-param name="codefct"
                                                  select="substring-after(@resource, 'http://id.loc.gov/vocabulary/relators/')"
                                                />
                                            </xsl:call-template>
                                        </propriete>
                                    </xsl:for-each>
                                    <xsl:for-each select="rank[@resource != '']">
                                        <propriete nom="RANG">
                                            <xsl:value-of select="normalize-space(.)"/>
                                        </propriete>
                                    </xsl:for-each>
                                    <!-- On ne garde pas l'Authorship, même si en sortie csv, elle réapparaitra comme Contribution... -->
                                    <xsl:for-each select="hasAuthorshipAffiliation[@resource != '']">
                                        <relation>
                                            <xsl:attribute name="xref">
                                                <xsl:value-of select="normalize-space(@resource)"/>
                                            </xsl:attribute>
                                            <type>A_POUR_AFFILIATION</type>
                                            <xsl:call-template name="meta"/>
                                        </relation>
                                    </xsl:for-each>
                                    <xsl:call-template name="meta"/>
                                </relation>
                            </xsl:for-each>
                        </xsl:for-each>
                        <!-- - - -->
                        <xsl:call-template name="meta">
                            <xsl:with-param name="id_source" select="$racineId"/>
                        </xsl:call-template>
                    </Entite>
                </xsl:if>
                <!-- Entite item -->
                <xsl:if
                    test="type[@resource = 'http://rdaregistry.info/Elements/c/C10007'] and (uri[text() != ''] | doi[text() != ''])">
                    <xsl:comment>Entite item</xsl:comment>
                    <xsl:variable name="idItem"
                        select="concat(substring-before($racineId, '/m/'), '/i/web')"/>
                    <Entite>
                        <xsl:attribute name="id" select="$idItem"/>
                        <!-- type d'item -->
                        <xsl:call-template name="types_relations">
                            <xsl:with-param name="mode" select="'type'"/>
                            <xsl:with-param name="racineId" select="$idItem"/>
                            <xsl:with-param name="id_source" select="$racineId"/>
                        </xsl:call-template>
                        <!-- propriétés  de l'item -->
                        <xsl:for-each select="doi[text() != '']">
                            <propriete nom="DOI">
                                <xsl:value-of select="normalize-space(.)"/>
                            </propriete>
                        </xsl:for-each>
                        <xsl:for-each select="uri[text() != '']">
                            <propriete nom="URI">
                                <xsl:value-of select="normalize-space(.)"/>
                            </propriete>
                        </xsl:for-each>
                        <!-- - - -->
                        <xsl:call-template name="meta">
                            <xsl:with-param name="id_source" select="$racineId"/>
                        </xsl:call-template>
                    </Entite>
                </xsl:if>
                <!-- Entités Nomens -->
                <xsl:for-each
                    select="title[text() != ''] | shortTitle[text() != ''] | alternative[text() != ''] | prefLabel[text() != ''] | familyName[text() != ''] | organization-name[text() != ''] | organization-unit[text() != ''] | affiliationContent[text() != ''] | name[parent::type/@resource = 'http://xmlns.com/foaf/0.1/Organization'][text() != '']">
                    <xsl:variable name="typeNomen">
                        <xsl:choose>
                            <xsl:when
                                test="name(.) = 'title' or name(.) = 'shortTitle' or name(.) = 'alternative'">
                                <xsl:text>TITRE</xsl:text>
                            </xsl:when>
                            <xsl:when test="name(.) = 'prefLabel'">
                                <xsl:text>NOM_COMMUN</xsl:text>
                            </xsl:when>
                            <xsl:when test="name(.) = 'familyName'">
                                <xsl:text>PERSONNE</xsl:text>
                            </xsl:when>
                            <xsl:when
                                test="name(.) = 'organization-name' or name(.) = 'organization-unit' or name(.) = 'affiliationContent' or name() = 'name'">
                                <xsl:text>COLLECTIVITE</xsl:text>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:variable>
                    <xsl:variable name="typeAcces">
                        <xsl:choose>
                            <xsl:when test="$typeNomen = 'TITRE' or $typeNomen = 'PERSONNE' or $typeNomen='COLLECTIVITE'">
                                <xsl:text>paa</xsl:text>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>vpa</xsl:text>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>
                    <xsl:call-template name="nomen">
                        <xsl:with-param name="racineId" select="$racineId"/>
                        <xsl:with-param name="type" select="$typeNomen"/>
                        <xsl:with-param name="typeAcces" select="$typeAcces"/>
                    </xsl:call-template>
                </xsl:for-each>
                <xsl:for-each select="publisher">
                    <xsl:variable name="uriNomen">
                        <xsl:choose>
                            <xsl:when test="@resource != ''">
                                <xsl:value-of select="@resource"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of
                                    select="concat($racineId, '/contexte/', position(), '/contrib/nomen')"
                                />
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>
                    <Entite id="{$uriNomen}">
                        <type lrm="NOMEN">NOMEN</type>
                        <type>COLLECTIVITE</type>
                        <propriete nom="TYPE_ACCES">ng</propriete>
                        <propriete nom="VALEUR">
                            <xsl:choose>
                                <xsl:when test="@resource != ''">
                                    <xsl:value-of
                                        select="/rdf/Description[@about = replace($racineId, '/m/web', '/m/print')]/normalize-space(publisher[1]/text())"
                                    />
                                </xsl:when>
                                <xsl:when test="normalize-space(text()) != ''">
                                    <xsl:value-of select="normalize-space(text())"/>
                                </xsl:when>
                            </xsl:choose>
                        </propriete>
                        <xsl:call-template name="meta">
                            <xsl:with-param name="id_source" select="$racineId"/>
                        </xsl:call-template>
                    </Entite>
                </xsl:for-each>
                <!-- Alignements : entités sameAs -->
                <xsl:for-each select="sameAs/@resource[. != '']">
                    <Entite id="{normalize-space(.)}"/>
                </xsl:for-each>
            </xsl:otherwise>
            <!-- fin du bloc principal (toute entité sauf Authorship et Volume-->
        </xsl:choose>
    </xsl:template>
    <!-- type de publication : monographie, périodique, collection (pubserie), article, chapitre -->
    <xsl:template name="types_relations">
        <xsl:param name="mode"/>
        <xsl:param name="racineId"/>
        <xsl:param name="id_source"/>
        <!-- type "lrm" -->
        <xsl:variable name="typeLRM">
            <xsl:choose>
                <!-- Expression (premier when, sinon c'est une oeuvre qui va être détectée -->
                <xsl:when test="ends-with($racineId, '/e')">
                    <xsl:choose>
                        <xsl:when
                            test="@resource = 'http://purl.org/ontology/bibo/Journal' or @resource = 'http://purl.org/ontology/bibo/Series'">
                            <xsl:text>EXPRESSION_AGREGATIVE</xsl:text>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:text>EXPRESSION</xsl:text>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:when test="type/@resource = 'http://rdaregistry.info/Elements/c/C10001'">
                    <xsl:choose>
                        <xsl:when
                            test="type[@resource = 'http://purl.org/ontology/bibo/Journal' or @resource = 'http://purl.org/ontology/bibo/Series']">
                            <xsl:text>OEUVRE_AGREGATIVE</xsl:text>
                        </xsl:when>
                        <!--<xsl:when test="type[@resource = 'http://purl.org/ontology/bibo/Issue']">
                            <xsl:text>MANIFESTATION AGREGATIVE</xsl:text>
                        </xsl:when>-->
                        <xsl:otherwise>
                            <xsl:text>OEUVRE</xsl:text>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:when test="ends-with($racineId, '/i/web')">
                    <xsl:choose>
                        <xsl:when
                            test="type[@resource = 'http://purl.org/ontology/bibo/Journal' or @resource = 'http://purl.org/ontology/bibo/Series' or @resource = 'http://purl.org/ontology/bibo/Issue']">
                            <xsl:text>ITEM_AGREGATIF</xsl:text>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:text>ITEM</xsl:text>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:when test="type/@resource = 'http://rdaregistry.info/Elements/c/C10007'">
                    <xsl:choose>
                        <xsl:when
                            test="type[@resource = 'http://purl.org/ontology/bibo/Journal' or @resource = 'http://purl.org/ontology/bibo/Series' or @resource = 'http://purl.org/ontology/bibo/Issue']">
                            <xsl:text>MANIFESTATION_AGREGATIVE</xsl:text>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:text>MANIFESTATION</xsl:text>
                        </xsl:otherwise>
                    </xsl:choose>
                    <!--                    <xsl:text>MANIFESTATION</xsl:text>-->
                </xsl:when>
                <xsl:when test="type/@resource = 'http://purl.org/ontology/bibo/Volume'">
                    <xsl:text>MANIFESTATION_AGREGATIVE</xsl:text>
                </xsl:when>
                <xsl:when
                    test="type[@resource = 'http://xmlns.com/foaf/0.1/Person' or @resource = 'http://xmlns.com/foaf/0.1/Organization']">
                    <xsl:text>AGENT</xsl:text>
                </xsl:when>
                <xsl:when test="type/@resource = 'http://www.w3.org/2004/02/skos/core#Concept'">
                    <xsl:text>CONCEPT</xsl:text>
                </xsl:when>
                <!--<xsl:when test="type/@resource = 'http://vivoweb.org/ontology/core#Authorship'">
                    <xsl:text>CONTEXTE</xsl:text>
                </xsl:when>-->
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="typeDoc">
            <xsl:comment>--- types "non-lrm" ---</xsl:comment>
            <xsl:choose>
                <xsl:when test="type/@resource = 'http://purl.org/ontology/bibo/Book'">
                    <xsl:text>MONOGRAPHIE</xsl:text>
                </xsl:when>
                <xsl:when test="type/@resource = 'http://purl.org/ontology/bibo/Journal'">
                    <xsl:text>PERIODIQUE</xsl:text>
                </xsl:when>
                <xsl:when test="type/@resource = 'http://purl.org/ontology/bibo/Series'">
                    <xsl:text>COLLECTION</xsl:text>
                </xsl:when>
                <xsl:when test="type/@resource = 'http://purl.org/ontology/bibo/Volume'">
                    <xsl:text>VOLUME</xsl:text>
                </xsl:when>
                <xsl:when test="type/@resource = 'http://purl.org/ontology/bibo/Issue'">
                    <xsl:text>NUMERO</xsl:text>
                </xsl:when>
                <xsl:when test="type/@resource = 'http://purl.org/ontology/bibo/Chapter'">
                    <xsl:text>CHAPITRE</xsl:text>
                </xsl:when>
                <xsl:when test="type/@resource = 'http://purl.org/ontology/bibo/Article'">
                    <xsl:text>ARTICLE</xsl:text>
                </xsl:when>
                <xsl:when test="type/@resource = 'http://purl.org/ontology/bibo/BookSection'">
                    <xsl:text>PARTIE</xsl:text>
                </xsl:when>
                <!--<xsl:when test="type/@resource = 'http://vivoweb.org/ontology/core#Authorship'">
                            <xsl:text>CONTRIBUTION</xsl:text>
                        </xsl:when>-->
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="typeMedia">
            <xsl:choose>
                <xsl:when test="ends-with($racineId, '/m/web')">
                    <!-- équivalent à P1003/@resource = 'http://iflastandards.info/ns/isbd/terms/mediatype/T1002' -->
                    <xsl:text>ELECTRONIQUE</xsl:text>
                </xsl:when>
                <xsl:when test="ends-with($racineId, '/m/print')">
                    <!-- équivalent à P1003/@resource = 'http://iflastandards.info/ns/isbd/terms/mediatype/T1010' -->
                    <xsl:text>IMPRIME</xsl:text>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="$mode = 'type'">
                <xsl:comment>--- type "lrm" ---</xsl:comment>
                <type lrm="{$typeLRM}">
                    <xsl:value-of select="$typeLRM"/>
                </type>
                <xsl:choose>
                    <xsl:when test="$typeDoc = 'PERIODIQUE' or $typeDoc='COLLECTION'">
                        <type>PUBSERIE</type>
                    </xsl:when>
                    <xsl:when test="$typeDoc = 'VOLUME' or $typeDoc = 'NUMERO' or $typeDoc = 'CHAPITRE' or $typeDoc = 'PARTIE' or $typeDoc = 'ARTICLE'">
                        <type>PARTIE_COMPOSANTE</type>
                    </xsl:when>
                    <xsl:when test="type/@resource = 'http://xmlns.com/foaf/0.1/Person'">
                        <type>PERSONNE</type>
                    </xsl:when>
                    <xsl:when test="type/@resource = 'http://xmlns.com/foaf/0.1/Organization'">
                        <type>COLLECTIVITE</type>
                    </xsl:when>
                </xsl:choose>
                <xsl:if test="$typeDoc != ''">
                    <xsl:comment>--- types "non-lrm" ---</xsl:comment>
                    <type>
                        <xsl:value-of select="$typeDoc"/>
                    </type>
                </xsl:if>
                <!-- type média : imprimé / électronique (manifestations) -->
                <xsl:if test="$typeMedia != ''">
                    <xsl:comment>--- types "non-lrm" ---</xsl:comment>
                    <type>
                        <xsl:value-of select="$typeMedia"/>
                    </type>
                </xsl:if>
            </xsl:when>
            <xsl:when test="$mode = 'relations'">
                <!-- Relations WEMI -->
                <xsl:choose>
                    <!-- expression => manifestation : premier when sinon une oeuvre sera détectée-->
                    <xsl:when test="starts-with($typeLRM, 'EXPRESSION')">
                        <xsl:for-each select="P10072/@resource[. != '']">
                            <relation>
                                <xsl:attribute name="xref" select="."/>
                                <type>A_POUR_MANIFESTATION</type>
                                <xsl:call-template name="meta"/>
                            </relation>
                        </xsl:for-each>
                    </xsl:when>
                    <xsl:when test="starts-with($typeLRM, 'OEUVRE')">
                        <relation>
                            <xsl:attribute name="xref"
                                select="concat(substring($racineId, 1, string-length($racineId) - 2), '/e')"/>
                            <type>A_POUR_EXPRESSION</type>
                            <xsl:call-template name="meta"/>
                        </relation>
                    </xsl:when>
                    <xsl:when
                        test="starts-with($typeLRM, 'MANIFESTATION') and ends-with($racineId, 'web') and (uri[text() != ''] | doi[text() != ''])">
                        <relation>
                            <xsl:attribute name="xref"
                                select="concat(substring-before($racineId, '/m/'), '/i/web')"/>
                            <type>A_POUR_ITEM</type>
                            <xsl:call-template name="meta"/>
                        </relation>
                    </xsl:when>
                </xsl:choose>
                <!-- Relations FAIT_PARTIE_DE / EST_AGREGE_DANS-->
                <!-- Calcul / récupération  de l'uri du document "parent" : article => issue => volume => revue ; chapitre => partie => livre => collection DANS LES MANIFESTATIONS-->
                <xsl:if test="starts-with($typeLRM, 'MANIFESTATION')">
                    <xsl:variable name="uriParent">
                        <xsl:choose>
                            <!-- Si c'est une mono (uri collection) ; sinon on construit l'uri parente -->
                            <xsl:when test="$typeDoc = 'MONOGRAPHIE'">
                                <xsl:for-each select="isPartOf/@resource">
                                    <xsl:value-of select="."/>
                                </xsl:for-each>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of
                                    select="replace(replace($racineId, '/chapter', ''), '/[^/]{1,}/m/', '/m/')"
                                />
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>
                    <xsl:choose>
                        <xsl:when
                            test="$typeDoc = 'VOLUME' or $typeDoc = 'NUMERO' or $typeDoc = 'MONOGRAPHIE'">
                            <relation>
                                <xsl:attribute name="xref" select="$uriParent"/>
                                <type>EST_AGREGE_DANS</type>
                                <xsl:if test="$typeDoc = 'MONOGRAPHIE'">
                                    <xsl:for-each select="volume[text() != '']">
                                        <propriete nom="NUM_VOL">
                                            <xsl:value-of select="normalize-space(.)"/>
                                        </propriete>
                                    </xsl:for-each>
                                </xsl:if>
                                <xsl:call-template name="meta"/>
                            </relation>
                        </xsl:when>
                        <xsl:when
                            test="$typeDoc = 'ARTICLE' or $typeDoc = 'CHAPITRE' or $typeDoc = 'PARTIE'">
                            <relation>
                                <xsl:attribute name="xref" select="$uriParent"/>
                                <type>FAIT_PARTIE_DE</type>
                                <xsl:call-template name="meta"/>
                            </relation>
                        </xsl:when>
                    </xsl:choose>
                </xsl:if>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    <!-- Volumes (revues) -->
    <xsl:template name="volume">
        <xsl:param name="racineId"/>
        <xsl:param name="id_source"/>
        <xsl:comment>test passage template volume</xsl:comment>
        <Entite id="{$racineId}">
            <xsl:call-template name="types_relations">
                <xsl:with-param name="mode" select="'type'"/>
                <xsl:with-param name="racineId" select="$racineId"/>
                <xsl:with-param name="id_source" select="$id_source"/>
            </xsl:call-template>
            <xsl:for-each select="volume[text() != '']">
                <propriete nom="NUM_VOL">
                    <xsl:value-of select="normalize-space(.)"/>
                </propriete>
            </xsl:for-each>
            <xsl:call-template name="types_relations">
                <xsl:with-param name="mode" select="'relations'"/>
                <xsl:with-param name="racineId" select="$racineId"/>
                <xsl:with-param name="id_source" select="$id_source"/>
            </xsl:call-template>
            <xsl:call-template name="meta">
                <xsl:with-param name="id_source" select="$id_source"/>
            </xsl:call-template>
        </Entite>
    </xsl:template>
    <!-- Nomens -->
    <xsl:template name="nomen">
        <xsl:param name="racineId"/>
        <xsl:param name="type"/>
        <xsl:param name="typeAcces"/>
        <Entite>
            <xsl:attribute name="id" select="concat($racineId, '/nomen/', position())"/>
            <type lrm="NOMEN">NOMEN</type>
            <type>
                <xsl:value-of select="$type"/>
            </type>
            <xsl:choose>
                <xsl:when test="$type = 'PERSONNE'">
                    <xsl:variable name="nom" select="normalize-space(.)"/>
                    <xsl:variable name="prenom"
                        select="normalize-space(parent::Description/givenName)"/>
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
                        <xsl:value-of select="normalize-space(.)"/>
                    </propriete>
                </xsl:when>
                <xsl:when test="$type = 'TITRE'">
                    <xsl:choose>
                        <xsl:when test="name(.) = 'shortTitle'">
                            <type>ABREGE</type>
                        </xsl:when>
                        <xsl:when test="name(.) = 'alternative'">
                            <type>ALTERNATIF</type>
                        </xsl:when>
                    </xsl:choose>
                    <propriete nom="VALEUR">
                        <xsl:value-of select="normalize-space(.)"/>
                        <xsl:for-each select="ancestor::Description/subTitle[text() != '']">
                            <xsl:value-of select="concat('&#x20;:&#x20;', normalize-space())"/>
                        </xsl:for-each>
                    </propriete>
                </xsl:when>
                <xsl:otherwise>
                    <propriete nom="VALEUR">
                        <xsl:value-of select="normalize-space(.)"/>
                    </propriete>
                </xsl:otherwise>
            </xsl:choose>
            <propriete nom="TYPE_ACCES">
                <xsl:value-of select="$typeAcces"/>
            </propriete>
            <!--        <propriete nom="langue">français</propriete>-->
            <propriete nom="ALPHABET">latin</propriete>
            <!-- - - -->
            <xsl:call-template name="meta">
                <xsl:with-param name="id_source" select="$racineId"/>
            </xsl:call-template>
        </Entite>
    </xsl:template>
    <xsl:template name="codeLangue">
        <xsl:param name="code"/>
        <xsl:variable name="codemap">;fr=français;en=anglais;de=allemand;es=espagnol;it=italien;pt=portugais;nl=néerlandais;la=latin;el=grec;ru=russe;ca=catalan;</xsl:variable>
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
    <xsl:template name="role">
        <xsl:param name="codefct"/>
        <xsl:variable name="rolemap"
            >;aut=Auteur;wpr=Préfacier;edt=Editeur&#x20;scientifique;ill=Illustrateur;pbl=Editeur&#x20;commercial;pbd=Directeur&#x20;de&#x20;publication;trl=Traducteur;</xsl:variable>
        <xsl:variable name="role"
            select="substring-before(substring-after($rolemap, concat(';', $codefct, '=')), ';')"/>
        <xsl:choose>
            <xsl:when test="$role != ''">
                <xsl:value-of select="$role"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>Contributeur</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template name="meta">
        <xsl:param name="id_source"/>
        <!--<xsl:param name="CITE_DANS"/>-->
        <propriete nom="META_SOURCE">RDF</propriete>
        <propriete nom="META_ACTEUR">XSL Pivot</propriete>
        <xsl:if test="$id_source != ''">
            <propriete nom="ID_SOURCE">
                <xsl:value-of select="$id_source"/>
            </propriete>
        </xsl:if>
    </xsl:template>
</xsl:stylesheet>
