<aura:application controller="TreeNodeDataProvider" extends="force:slds" >
    <aura:attribute name="nodes" type="Object" />
    <aura:handler name="init" value="{!this}" action="{!c.init}" />
    <aura:iteration items="{!v.nodes}" var="node">
        <c:TreeNode node="{!node}" />
    </aura:iteration>
</aura:application>