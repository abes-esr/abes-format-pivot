<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="2.0">
    <xsl:output method="text" encoding="UTF-8" omit-xml-declaration="yes"/>
    <xsl:template match="CollWemi">
        <xsl:text>@prefix abes: &lt;http://www.abes.fr/ontologie/&gt;.&#10;&#10;</xsl:text>
        <xsl:apply-templates select="Wemi[propriete]"/>
        <xsl:apply-templates select="Wemi/Entite|Entite"/>
    </xsl:template>
    <xsl:template match="Wemi">
        <xsl:variable name="sujet">
            <xsl:text>&lt;</xsl:text>
            <xsl:call-template name="majPPNx">
                <xsl:with-param name="uri" select="@id"/>
            </xsl:call-template>
            <xsl:text>&gt;</xsl:text>
        </xsl:variable>
        <xsl:value-of select="$sujet"/>
        <xsl:text>&#10;</xsl:text>
        <xsl:for-each-group select="propriete" group-by="@nom">
            <xsl:call-template name="propriete"/>
        </xsl:for-each-group>
    </xsl:template>
    <xsl:template match="Entite">
        <xsl:variable name="sujet">
            <xsl:text>&lt;</xsl:text>
            <xsl:call-template name="majPPNx">
                <xsl:with-param name="uri" select="@id"/>
            </xsl:call-template>
            <xsl:text>&gt;</xsl:text>
        </xsl:variable>
        <!-- sujet -->
        <xsl:value-of select="$sujet"/>
        <xsl:text>&#10;</xsl:text>
        <!-- rdf:type -->
        <xsl:for-each select="type">
            <xsl:choose>
                <xsl:when test="text()='OEUVRE' and following-sibling::type[text()='THESE']">
                </xsl:when>
                <xsl:when test="text()='THESE' and not(preceding-sibling::type[text()='OEUVRE'])">
                </xsl:when>
                <xsl:otherwise>
                    <xsl:choose>
                        <xsl:when test="text()='MONOGRAPHIE' and following-sibling::type[text(),'THESE'] and preceding-sibling::type[text()='OEUVRE']">
                            <xsl:text>&#x9;rdf:type </xsl:text>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:if test="position()=1">
                                <xsl:text>&#x9;rdf:type </xsl:text>
                            </xsl:if>
                        </xsl:otherwise>
                    </xsl:choose>
                    <!-- classe -->
                    <xsl:variable name="classe">
                        <xsl:variable name="classePivot">
                            <xsl:value-of select="concat('abes:', replace(concat(substring(.,1,1),lower-case(substring(.,2))),' ','_'))"/>
                        </xsl:variable>
                        <xsl:choose>
                            <xsl:when test="contains($classePivot,'_')">
                                <xsl:value-of select="substring-before($classePivot,'_')"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="$classePivot"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>
                    <xsl:value-of select="$classe"/>
                    <!-- type suivant, ou fin du triplet et saut de ligne -->
                    <xsl:choose>
                        <xsl:when test="position() != last()">
                            <xsl:text>, </xsl:text>
                        </xsl:when>
                        <xsl:when test="following-sibling::*">
                            <xsl:text> ;&#10;</xsl:text>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:text>.&#10;</xsl:text>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
        <!-- On recherche les propriétés et les relations de l'entité-->
        <xsl:for-each-group select="propriete | relation" group-by="type | @nom">
            <xsl:choose>
                <xsl:when test="name() = 'propriete'">
                    <xsl:call-template name="propriete"/>
                </xsl:when>
                <xsl:when test="name() = 'relation'">
                    <xsl:choose>
                        <xsl:when test="type = 'A_POUR_MENTION'">
                            <xsl:call-template name="mentionContrib">
                                <xsl:with-param name="mode" select="'relation'"/>
                                <xsl:with-param name="sujet" select="$sujet"/>
                            </xsl:call-template>
                        </xsl:when>
                        <xsl:when test="type = 'A_POUR_INDEXATION'">
                            <xsl:call-template name="boiteSujets">
                                <xsl:with-param name="mode" select="'relation'"/>
                                <xsl:with-param name="sujet" select="$sujet"/>
                            </xsl:call-template>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:call-template name="relation">
                                <!--<xsl:with-param name="sujet" select="$sujet"/>-->
                            </xsl:call-template>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
            </xsl:choose>
        </xsl:for-each-group>
        <!-- 2e passage : réification des triplets (propriétés et relations de relations) -->
        <xsl:for-each-group select="relation[.//propriete or .//relation]" group-by="type">
            <xsl:choose>
                <xsl:when test="type = 'A_POUR_MENTION'">
                    <xsl:call-template name="mentionContrib">
                        <xsl:with-param name="mode" select="'reification'"/>
                        <xsl:with-param name="sujet" select="$sujet"/>
                    </xsl:call-template>
                </xsl:when>
                <xsl:when test="type = 'A_POUR_INDEXATION'">
                    <xsl:call-template name="boiteSujets">
                        <xsl:with-param name="mode" select="'reification'"/>
                        <xsl:with-param name="sujet" select="$sujet"/>
                    </xsl:call-template>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:call-template name="reification">
                        <xsl:with-param name="sujet" select="$sujet"/>
                    </xsl:call-template>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each-group>
        <!-- 3e passage : 2e niveau de réification (propriétés métas de relation de relation... (affiliation et spécifications de sujets, lieu, temps) -->
        <!--<xsl:for-each-group select="relation[Entite/relation2]|relation[relation]" group-by="type">
            <xsl:choose>
                <!-\- Cas de l'indexation matière-\->
                <xsl:when test="Entite/relation2">
                    <xsl:call-template name="boiteSujets">
                        <xsl:with-param name="mode" select="'reification2'"/>
                        <xsl:with-param name="sujet" select="$sujet"/>
                    </xsl:call-template>
                </xsl:when>
                <!-\- Cas des affiliations -\->
                <xsl:otherwise>
                    <xsl:call-template name="reification">
                        <xsl:with-param name="mode" select="'reification2'"/>
                        <xsl:with-param name="sujet" select="$sujet"/>
                    </xsl:call-template>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each-group>-->
        <!-- Ajout d'un type "LRM" sur la relation quand @lrm -->
 <!--       <xsl:for-each select="type/@lrm">
            <xsl:text>&#x9;&lt;&lt; </xsl:text>
            <xsl:value-of select="concat($sujet,' rdf:type ','abes:', concat(substring(.,1,1),lower-case(substring(.,2))))"/>
            <xsl:text> &gt;&gt; rdf:type abes:LRM.&#10;</xsl:text>
        </xsl:for-each>-->
    </xsl:template>
    <xsl:template name="propriete">
        <!-- prédicat -->
        <xsl:value-of select="concat('&#x9;abes:', lower-case(current-grouping-key()), ' ')"/>
        <!-- objet -->
        <xsl:for-each select="current-group()[@nom=current-grouping-key()]">
            <xsl:variable name="objet">
                <xsl:value-of select="normalize-space(concat('&quot;', replace(replace(replace(text(),'&#x98;',''),'&#x9c;',''),'&quot;','&amp;quot;'), '&quot;'))"/>
                <xsl:for-each select="@lang">
                    <xsl:text>@</xsl:text>
                    <xsl:call-template name="codeLangue">
                        <xsl:with-param name="code" select="normalize-space(.)"/>
                    </xsl:call-template>
                </xsl:for-each>
                <xsl:choose>
                    <xsl:when test="position() != last()">
                        <xsl:text>, </xsl:text>
                    </xsl:when>
                    <xsl:otherwise/>
                </xsl:choose>
            </xsl:variable>
            <xsl:value-of select="$objet"/>
        </xsl:for-each>
        <!-- propriété ou relation suivante, ou fin du triplet et saut de ligne -->
        <xsl:choose>
            <xsl:when test="position() = last()">
                <xsl:text>.&#10;</xsl:text>
            </xsl:when>
            <xsl:otherwise> ;&#10;</xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template name="relation">
        <xsl:param name="mode"/>
        <xsl:param name="tripletReifie"/>
        <!-- prédicat -->
        <xsl:value-of select="concat('&#x9;abes:', lower-case(current-grouping-key()), ' ')"/>
        <!-- objet -->
        <xsl:for-each select="current-group()[type=current-grouping-key()]/@xref">
            <xsl:variable name="objet">
                <xsl:text>&lt;</xsl:text>
                <xsl:call-template name="majPPNx">
                    <xsl:with-param name="uri" select="."/>
                </xsl:call-template>
                <xsl:text>&gt;</xsl:text>
                <!--<xsl:value-of select="concat('&lt;',., '&gt;')"/>-->
            </xsl:variable>
                <xsl:value-of select="$objet"/>
                    <xsl:choose>
                        <xsl:when test="position() != last()">
                            <xsl:text>, </xsl:text>
                        </xsl:when>
                        <xsl:otherwise/>
                    </xsl:choose>
        </xsl:for-each>
        <!-- propriété ou relation suivante, ou fin du triplet et saut de ligne -->
        <xsl:choose>
            <xsl:when test="position() = last()">
                <xsl:text>.&#10;</xsl:text>
            </xsl:when>
            <xsl:otherwise> ;&#10;</xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template name="boiteSujets">
        <xsl:param name="mode"/>
        <xsl:param name="sujet"/>
        <!-- prédicat -->
        <xsl:variable name="predicat">
            <xsl:text>abes:a_pour_sujet </xsl:text>
        </xsl:variable>
        <xsl:if test="$mode='relation'">
            <xsl:value-of select="concat('&#x9;', $predicat)"/>
        </xsl:if>
        <xsl:for-each select="current-group()">
        <!-- objet : on prend la tête de vedette ; les subdivisions seront traitées comme spécifications de la relation (réification) -->
        <xsl:variable name="objet">
            <xsl:text>&lt;</xsl:text>
            <xsl:call-template name="majPPNx">
                <xsl:with-param name="uri" select="Entite/relation/@xref"/>
            </xsl:call-template>
            <xsl:text>&gt;</xsl:text>
           <!-- <xsl:value-of select="concat('&lt;', Entite/relation/@xref, '&gt;')"/>-->
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="$mode = 'relation'">
                <xsl:value-of select="$objet"/>
                <xsl:choose>
                    <xsl:when test="position() != last()">
                        <xsl:text>, </xsl:text>
                    </xsl:when>
                    <xsl:otherwise/>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="starts-with($mode, 'reification')">
                <xsl:variable name="TripletReifie">
                    <xsl:text>&#x9;&lt;&lt; </xsl:text>
                    <xsl:value-of select="concat($sujet,' ',$predicat, $objet)"/>
                    <xsl:text> &gt;&gt;&#10;</xsl:text>
                </xsl:variable>
                <xsl:if test="$mode = 'reification'">
                    <xsl:value-of select="$TripletReifie"/>
                </xsl:if>
                <xsl:for-each-group select="Entite/propriete  | Entite/relation2" group-by="type | @nom">
                    <xsl:choose>
                        <xsl:when test="$mode='reification2' and name()='relation2'">
                            <xsl:text>&#x9;&lt;&lt; </xsl:text>
                            <!-- sujet réification 1 -->
                            <xsl:value-of select="$TripletReifie"/>
                            <!-- prédicat réification 1-->
                            <xsl:value-of select="concat('&#x9;&#x9;abes:', lower-case(current-grouping-key()), ' ')"/>
                            <!-- objet réification 1 -->
                            <xsl:text>&lt;</xsl:text>
                            <xsl:call-template name="majPPNx">
                                <xsl:with-param name="uri" select="./@xref"></xsl:with-param>
                            </xsl:call-template>
                            <xsl:text>&gt;</xsl:text>
                            <!--<xsl:value-of select="concat(' &lt;', ./@xref, '&gt; ')"/>-->
                            <xsl:text> &gt;&gt;&#10;</xsl:text>
                            <xsl:for-each-group select="propriete" group-by="@nom">
                                <xsl:call-template name="propriete2"/>
                            </xsl:for-each-group>
                        </xsl:when>
                        <xsl:when test="$mode!='reification2' and name() = 'propriete'">
                            <xsl:text>&#x9;</xsl:text>
                            <xsl:call-template name="propriete"/>
                        </xsl:when>
                        <xsl:when test="name() = 'relation2'">
                            <xsl:text>&#x9;</xsl:text>
                            <xsl:call-template name="relation"/>
                        </xsl:when>
                    </xsl:choose>
                </xsl:for-each-group>
            </xsl:when>
        </xsl:choose>
        </xsl:for-each>
        <xsl:if test="$mode='relation'">
            <!-- propriété ou relation suivante, ou fin du triplet et saut de ligne -->
            <xsl:choose>
                <xsl:when test="position() = last()">
                    <xsl:text>.&#10;</xsl:text>
                </xsl:when>
                <xsl:otherwise> ;&#10;</xsl:otherwise>
            </xsl:choose>
        </xsl:if>
    </xsl:template>
    <xsl:template name="mentionContrib">
        <xsl:param name="mode"/>
        <xsl:param name="sujet"/>
        <!-- prédicat -->
        <xsl:variable name="predicat">
            <xsl:text>abes:a_pour_mention_de_contributeur </xsl:text>
        </xsl:variable>
        <xsl:if test="$mode='relation'">
            <xsl:value-of select="concat('&#x9;', $predicat)"/>
        </xsl:if>
        <xsl:for-each select="current-group()">
        <!-- objet -->
        <xsl:variable name="objet">
            <xsl:text>&lt;</xsl:text>
            <xsl:call-template name="majPPNx">
                <xsl:with-param name="uri" select="Entite/relation[type = 'A_POUR_MENTION_DE_CONTRIBUTEUR']/@xref"/>
            </xsl:call-template>
            <xsl:text>&gt;</xsl:text>
            <!--<xsl:value-of select="concat('&lt;', Entite/relation[type = 'A_POUR_MENTION_DE_CONTRIBUTEUR']/@xref, '&gt;')" />-->
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="$mode = 'relation'">
                <xsl:value-of select="$objet"/>
                <xsl:choose>
                    <xsl:when test="position() != last()">
                        <xsl:text>, </xsl:text>
                    </xsl:when>
                    <xsl:otherwise/>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="$mode = 'reification'">
                <xsl:variable name="TripletReifie">
                    <xsl:text>&#x9;&lt;&lt; </xsl:text>
                    <xsl:value-of select="concat($sujet,' ',$predicat, $objet)"/>
                    <xsl:text> &gt;&gt;&#10;</xsl:text>
                </xsl:variable>
                <xsl:value-of select="$TripletReifie"/>
                <xsl:for-each-group select="Entite/propriete" group-by="type | @nom"> <!-- | Entite/relation[not(type = 'A_POUR_MENTION_DE_CONTRIBUTEUR')]-->
                    <xsl:choose>
                        <xsl:when test="name() = 'propriete'">
                            <xsl:text>&#x9;</xsl:text>
                            <xsl:call-template name="propriete"/>
                        </xsl:when>
                    </xsl:choose>
                </xsl:for-each-group>
            </xsl:when>
        </xsl:choose>
        </xsl:for-each>
        <xsl:if test="$mode='relation'">
            <!-- propriété ou relation suivante, ou fin du triplet et saut de ligne -->
            <xsl:choose>
                <xsl:when test="position() = last()">
                    <xsl:text>.&#10;</xsl:text>
                </xsl:when>
                <xsl:otherwise> ;&#10;</xsl:otherwise>
            </xsl:choose>
        </xsl:if>
    </xsl:template>
    <xsl:template name="reification">
        <xsl:param name="mode"/>
        <xsl:param name="sujet"/>
        <!-- prédicat du triplet -->
        <xsl:variable name="predicat">
            <xsl:value-of select="concat(' abes:', lower-case(current-grouping-key()), ' ')"/>
        </xsl:variable>
        <xsl:for-each select="current-group()">
            <xsl:variable name="objet">
                <xsl:text>&lt;</xsl:text>
                <xsl:call-template name="majPPNx">
                    <xsl:with-param name="uri" select="@xref"/>
                </xsl:call-template>
                <xsl:text>&gt;</xsl:text>
                <!--<xsl:value-of select="concat('&lt;', @xref, '&gt;')"/>-->
            </xsl:variable>
            <xsl:variable name="TripletReifie">
                <xsl:text>&#x9;&lt;&lt; </xsl:text>
                <xsl:value-of select="concat($sujet, $predicat, $objet)"/>
                <xsl:text> &gt;&gt;&#10;</xsl:text>
            </xsl:variable>
            <xsl:if test="$mode != 'reification2'">
                <xsl:value-of select="$TripletReifie"/>
            </xsl:if>
            <xsl:for-each-group select="propriete | relation" group-by="type | @nom">
            <xsl:choose>
                <xsl:when test="$mode!='reification2' and name() = 'propriete'">
                    <xsl:text>&#x9;</xsl:text>
                    <xsl:call-template name="propriete"/>
                </xsl:when>
                <xsl:when test="$mode='reification2' and name() = 'relation'">
                    <xsl:text>&#x9;&lt;&lt; </xsl:text>
                    <!-- sujet réification 1 -->
                    <xsl:value-of select="$TripletReifie"/>
                    <!-- prédicat réification 1-->
                    <xsl:value-of select="concat('&#x9;abes:', lower-case(current-grouping-key()), ' ')"/>
                    <!-- objet réification 1 -->
                    <xsl:value-of select="concat(' &lt;', ./@xref, '&gt; ')"/>
                    <xsl:text> &gt;&gt;&#10;</xsl:text>
                    <xsl:for-each-group select="propriete" group-by="@nom">
                        <xsl:call-template name="propriete2"/>
                    </xsl:for-each-group>
                </xsl:when>
                <xsl:when test="name() = 'relation'">
                    <xsl:text>&#x9;</xsl:text>
                    <xsl:call-template name="relation"/>
                </xsl:when>
            </xsl:choose>
            </xsl:for-each-group>
        </xsl:for-each>
    </xsl:template>
    <xsl:template name="propriete2"> <!-- Uniquement pour les propriétés de relations de relations ! (Affiliations, spécifications de sujet, lieu ou temps)-->
        <!-- prédicat -->
        <xsl:value-of select="concat('&#x9;abes:', lower-case(current-grouping-key()), ' ')"/>
        <!-- objet -->
        <xsl:for-each select="current-group()[@nom=current-grouping-key()]">
            <xsl:variable name="objet">
                <xsl:value-of select="concat('&quot;', replace(replace(replace(text(),'&#x98;',''),'&#x9c;',''),'&quot;','&amp;quot;'), '&quot;')"/>
                <xsl:choose>
                    <xsl:when test="position() != last()">
                        <xsl:text>, </xsl:text>
                    </xsl:when>
                    <xsl:otherwise/>
                </xsl:choose>
            </xsl:variable>
            <xsl:value-of select="$objet"/>
        </xsl:for-each>
        <!-- propriété ou relation suivante, ou fin du triplet et saut de ligne -->
        <xsl:choose>
            <xsl:when test="position() = last()">
                <xsl:text>.&#10;</xsl:text>
            </xsl:when>
            <xsl:otherwise> ;&#10;</xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!-- mapping pour tag langue (résumés et keywords) -->
    <xsl:template name="codeLangue">
        <xsl:param name="code"/>
        <xsl:variable name="codemap">;français=fr;fre=fr;anglais=en;eng=en;allemand=de;ger=de;espagnol=es;spa=es;italien=it;portugais=pt;néerlandais=nl;latin=la;grec=el;russe=ru;catalan=ca;</xsl:variable>
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
    <!-- correction des uris avec des ppns x +=> X -->
    <xsl:template name="majPPNx">
    <xsl:param name="uri"/>
        <xsl:choose>
            <xsl:when test="matches($uri,'http://www.abes.fr/[0-9]{8}x.*')">
                <xsl:value-of select="replace($uri,'x/','X/')"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$uri"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
</xsl:stylesheet>
