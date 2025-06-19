<%--
   Copyright 2024 Adobe. All rights reserved.
   This file is licensed to you under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License. You may obtain a copy
   of the License at http://www.apache.org/licenses/LICENSE-2.0
   
   Unless required by applicable law or agreed to in writing, software distributed under
   the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR REPRESENTATIONS
   OF ANY KIND, either express or implied. See the License for the specific language
   governing permissions and limitations under the License.
--%><%
%><%@include file="/libs/granite/ui/global.jsp" %><%
%><%@ page session="false" contentType="text/html" pageEncoding="utf-8"
         import="org.apache.sling.api.resource.ValueMap" %><%

	ValueMap fieldProperties = resource.adaptTo(ValueMap.class);
    boolean showRoles = "true".equals(fieldProperties.get("field/showRoles", "false"));
    boolean showOrder = "true".equals(fieldProperties.get("field/showOrder", "false"));
	String key = resource.getName();
    String resourcePathBase = "dam/gui/coral/components/admin/schemaforms/formbuilder/formfieldproperties/";
%>

<div class="formbuilder-content-form" role="gridcell">
    <label class="fieldtype">
        <coral-icon alt="" icon="text" size="XS"></coral-icon>
        <%= xssAPI.encodeForHTML(i18n.get("Multi Value Text Field")) %>
    </label>
    <sling:include resource="<%= resource %>" resourceType="granite/ui/components/coral/foundation/form/textfield"/>
</div>
<div class="formbuilder-content-properties">

    <input type="hidden" name="<%= xssAPI.encodeForHTMLAttr("./items/" + key) %>">
    <input type="hidden" name="<%= xssAPI.encodeForHTMLAttr("./items/" + key + "/jcr:primaryType") %>" value="nt:unstructured">
    <input type="hidden" name="<%= xssAPI.encodeForHTMLAttr("./items/" + key + "/resourceType") %>" value="granite/ui/components/coral/foundation/form/multifield">
    <input type="hidden" name="<%= xssAPI.encodeForHTMLAttr("./items/" + key + "/sling:resourceType") %>" value="dam/gui/components/admin/schemafield">
    <input type="hidden" name="<%= xssAPI.encodeForHTMLAttr("./items/" + key + "/granite:data/metaType") %>" value="mvproductdata">
    <input type="hidden" name="<%= xssAPI.encodeForHTMLAttr("./items/" + key + "/field") %>">
    <input type="hidden" name="<%= xssAPI.encodeForHTMLAttr("./items/" + key + "/field/jcr:primaryType") %>" value="nt:unstructured">
    <input type="hidden" name="<%= xssAPI.encodeForHTMLAttr("./items/" + key + "/field/sling:resourceType") %>" value="commerce/ui/components/productdata">



    <sling:include resource="<%= resource %>" resourceType="<%= resourcePathBase + "labelfields"%>"/>
    <%request.setAttribute("cq.dam.metadataschema.builder.field.relativeresource", "field"); %>
    <sling:include resource="<%= resource %>" resourceType="<%= resourcePathBase + "metadatamappertextfield"%>"/>
    <%request.removeAttribute("cq.dam.metadataschema.builder.field.relativeresource"); %>
    <sling:include resource="<%= resource %>" resourceType="<%= resourcePathBase + "placeholderfields"%>"/>

    <%request.removeAttribute("cq.dam.metadataschema.builder.field.relativeresource"); %>

    <sling:include resource="<%= resource %>" resourceType="<%= resourcePathBase + "titlefields" %>" />
    <% if (showRoles) {%>
       <coral-checkbox checked coral-interactive name="<%= xssAPI.encodeForHTMLAttr("./items/" + key + "/field/showRoles") %>" value="true"><span>Show Roles</span></coral-checkbox> 
    <%} else { %>
       <coral-checkbox coral-interactive name="<%= xssAPI.encodeForHTMLAttr("./items/" + key + "/field/showRoles") %>" value="true"><span>Show Roles</span></coral-checkbox>
    <% }
     if (showOrder) {%>
       <coral-checkbox checked coral-interactive name="<%= xssAPI.encodeForHTMLAttr("./items/" + key + "/field/showOrder") %>" value="true"><span>Show Positions</span></coral-checkbox>
    <%} else { %>
     <coral-checkbox coral-interactive name="<%= xssAPI.encodeForHTMLAttr("./items/" + key + "/field/showOrder") %>" value="true"><span>Show Positions</span></coral-checkbox>
    <% } %>
    <coral-icon class="delete-field" icon="delete" size="L" tabindex="0" role="button" alt="<%= xssAPI.encodeForHTMLAttr(i18n.get("Delete")) %>" data-target-id="<%= xssAPI.encodeForHTMLAttr(key) %>" data-target="<%= xssAPI.encodeForHTMLAttr("./items/" + key + "@Delete") %>"></coral-icon>
</div>
<div class="formbuilder-content-properties-rules">
    <label for="field">
    	<span class="rules-label"><%= i18n.get("Field") %></span>
        <%
            String[] fieldRulesList = {"showemptyfieldinreadonly"};
            for(String ruleComponent : fieldRulesList){
                %>
                    <sling:include resource="<%= resource %>" resourceType="<%= resourcePathBase + ruleComponent %>"/>
                <%
            }

        %>
    </label>  
    <label for="requirement">
        <span class="rules-label"><%= i18n.get("Requirement") %></span>
        <% String requiredField = "v2/requiredfields"; %>
        <sling:include resource="<%= resource %>" resourceType="<%= resourcePathBase + requiredField %>"/>
    </label> 
    <label for="visibililty">    
        <span class="rules-label"><%= i18n.get("Visibility") %></span>
        <% String visibilityField = "visibilityfields"; %>
        <sling:include resource="<%= resource %>" resourceType="<%= resourcePathBase + visibilityField %>"/>
    </label>     
</div>
