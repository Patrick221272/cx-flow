package com.checkmarx.flow.cucumber.integration.scan;

import com.checkmarx.flow.config.FlowProperties;
import com.checkmarx.flow.config.GitHubProperties;
import com.checkmarx.flow.dto.BugTracker;
import com.checkmarx.flow.dto.ScanDetails;
import com.checkmarx.flow.dto.ScanRequest;
import com.checkmarx.flow.exception.MachinaException;
import com.checkmarx.flow.service.FlowService;
import com.checkmarx.sdk.config.Constants;
import com.checkmarx.sdk.config.CxProperties;
import com.checkmarx.sdk.dto.Filter;
import com.checkmarx.sdk.dto.ScanResults;
import com.checkmarx.sdk.dto.cx.CxProject;
import com.checkmarx.sdk.exception.CheckmarxException;
import com.checkmarx.sdk.service.CxClient;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.util.LinkedList;
import java.util.List;
import java.util.concurrent.CompletableFuture;

import static org.junit.Assert.fail;

@Component
public  abstract class AbstractScanSteps {


    @Autowired
    protected FlowProperties flowProperties;
    @Autowired
    protected CxProperties cxProperties;
    @Autowired
    protected GitHubProperties gitHubProperties;
    @Autowired
    protected FlowService flowService;
    @Autowired
    protected CxClient cxClient;

    protected String projectName;
    protected String teamName;
    protected String branch = "master";
    protected String preset = "Checkmarx Default";
    protected String repoUrl;
    protected String repoName;
    protected String gitAuthUrl;
    protected String namespace;
    protected String application;
    protected ScanRequest.Product product = ScanRequest.Product.CX;
    protected ScanResults results;
    protected ScanRequest.Repository repoType;

    protected ScanDetails scanDetails;

    protected List<Filter> filters = new LinkedList<>();
    protected List<String> excludeFoldersList = new LinkedList<>();
    protected List<String> excludeFilesList = new LinkedList<>();
    
    protected void setGithubAuthURL() {
        String url = gitHubProperties.getUrl();
        String[] urlSegments = url.split("github");
        this.gitAuthUrl = urlSegments[0] + gitHubProperties.getToken() + "@github" + urlSegments[1];

        this.repoType = ScanRequest.Repository.GITHUB;
    }

    protected ScanDTO callSast() {

        ScanRequest request = generateRequest();
        
        try {
            scanDetails =  flowService.executeCxScan(request,null);
            CompletableFuture<ScanResults> future = new CompletableFuture<>();
            //TODO async these, and join and merge after
            results = cxClient.getReportContentByScanId(scanDetails.getScanId(), request.getFilters());
            future.complete(results);
            results = future.join();
            

            if(flowProperties.isBreakBuild() && results !=null && results.getXIssues()!=null && !results.getXIssues().isEmpty()){
                fail("break build");
            }
        } catch (MachinaException | CheckmarxException e) {
            fail(e.getMessage());
        }
        return retainOutputValues();
    }

    private ScanRequest generateRequest() {

        ScanRequest request = ScanRequest.builder()
                .application(this.application)
                .product(this.product)
                .project(this.projectName)
                .team(this.teamName)
                .namespace(this.namespace)
                .repoName(this.repoName)
                .repoUrl(this.repoUrl)
                .repoUrlWithAuth(this.gitAuthUrl)
                .repoType(repoType)
                .branch(this.branch)
                .refs(Constants.CX_BRANCH_PREFIX.concat(this.branch))
                .mergeNoteUri(null)
                .mergeTargetBranch(null)
                .email(null)
                .incremental(false)
                .scanPreset(this.preset)
                .bugTracker(BugTracker.builder().type(BugTracker.Type.CUSTOM).customBean("").build())
                .build();
        
        if(!filters.isEmpty()){
            request.setFilters(filters);
        }
        if(!excludeFilesList.isEmpty()){
            request.setExcludeFiles(excludeFilesList);
        }
        if(!excludeFoldersList.isEmpty()){
            request.setExcludeFolders(excludeFoldersList);
        }
        return request;
    }

    protected ScanDTO retainOutputValues() {
        
        CxProject cxProject = cxClient.getProject(scanDetails.getProjectId());

        ScanDTO scanDTO = new ScanDTO(scanDetails.getProjectId(), scanDetails.getScanId(), cxProject.getTeamId());
        return scanDTO;

    }
}