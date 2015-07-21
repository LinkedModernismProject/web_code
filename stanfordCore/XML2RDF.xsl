<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE rdf:RDF [
  <!ENTITY rdf "http://www.w3.org/1999/02/22-rdf-syntax-ns#">
  <!ENTITY ns "http://modernism.uvic.ca/metadata#">
]>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
    xmlns:rdf="&rdf;">
    
    <xsl:strip-space elements="*"/>
    <xsl:output indent="yes"/>
        
    <xsl:template match="/">
        <rdf:RDF xmlns:rdf='&rdf;'
                 xmlns:ns="&ns;">
            <xsl:call-template name="element"/>
        </rdf:RDF>
    </xsl:template>
        
    <xsl:template match="*" name="element">
        <xsl:variable name="separate-descriptions"
                      select="*[count(@*|*)>0 and count(text())=0]"/>
        <rdf:Description rdf:nodeID="{generate-id()}" xmlns="&ns;">
            <xsl:for-each select="@*">
                <xsl:attribute name="{local-name()}" namespace="&ns;">
                    <xsl:value-of select="."/>
                </xsl:attribute> 
            </xsl:for-each>
            
            <xsl:for-each select="$separate-descriptions">
                <xsl:element name="{local-name()}">
                    <xsl:attribute name="rdf:nodeID" select="generate-id()"/>
                </xsl:element>
            </xsl:for-each>
            
            <xsl:for-each select="* except $separate-descriptions">
                <xsl:element name="{local-name()}">
                    <xsl:choose>
                        <xsl:when test="count(*)>0">
                            <xsl:attribute name="rdf:parseType"
                                >Literal</xsl:attribute>
                            <xsl:copy-of select="*|text()" 
                                copy-namespaces="no"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="."/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:element>
            </xsl:for-each>
        </rdf:Description>
        <xsl:apply-templates select="$separate-descriptions"/>
    </xsl:template>
</xsl:stylesheet>