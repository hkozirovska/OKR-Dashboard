import { LightningElement, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import getObjectivesByUserAndYear from '@salesforce/apex/ObjectiveController.getObjectivesByUserAndYear';
import createObjective from '@salesforce/apex/ObjectiveController.createObjective';
import getKeyResults from '@salesforce/apex/KeyResultController.getKeyResults';
import createKeyResult from '@salesforce/apex/KeyResultController.createKeyResult';
import getUsers from '@salesforce/apex/UserSelectionController.getUsers';
import getNearest10Years from '@salesforce/apex/ObjectiveController.getNearest10Years';
import getRelatedRecords from '@salesforce/apex/RelatedRecordController.getRelatedRecords';
import createRelatedRecord from '@salesforce/apex/RelatedRecordController.createRelatedRecord';
import addTarget from '@salesforce/apex/KeyResultController.addTarget';
import updateTargetScore from '@salesforce/apex/KeyResultController.updateTargetScore';
import { refreshApex } from '@salesforce/apex';

export default class OkrDashboard extends NavigationMixin(LightningElement) {
    @track objectives;
    @track keyResults;
    @track isModalOpen = false;
    @track objectiveName = '';
    @track objectiveYear;
    @track isNewKeyResultModalOpen = false;
    @track newKeyResultName = '';
    @track selectedObjectiveId;
    @track selectedUserId;
    @track selectedYear;
    @track userId;
    @track userOptions = [];
    @track yearOptions = [];
    @track isRelatedRecordsModalOpen = false;
    @track relatedRecords;
    @track selectedKeyResultId;
    @track isNewRelatedRecordModalOpen = false;
    @track relatedRecordName = '';
    @track relatedRecordType = '';
    @track relatedRecordTypeOptions = [
        { label: 'Survey', value: 'Survey' },
        { label: 'Review', value: 'Review' },
        { label: 'Google Review', value: 'Google Review' },
        { label: 'Case Study', value: 'Case Study' },
    ];
    @track targetOptions = [
        { label: 'Calls', value: 'Calls' },
        { label: 'Events', value: 'Events' },
        { label: 'Opportunities', value: 'Opportunities' },
        { label: 'Contracts', value: 'Contracts' },
        { label: 'Leads', value: 'Leads' },
        { label: 'Surveys', value: 'Surveys' },
        { label: 'Reviews', value: 'Reviews' },
        { label: 'Google Reviews', value: 'Google reviews' },
        { label: 'Case Studies', value: 'Case studies' }
    ];
    @track isNewTargetModalOpen = false;
    @track selectedTarget = '';
    @track targetScore = 0;
    @track keyResultIdToAddTarget = '';
    connectedCallback() {
        this.loadInitialData();
    }

    loadInitialData() {
        getUsers().then(data => {
            this.userOptions = data.map(user => ({
                label: user.Name,
                value: user.Id
            }));
            this.selectedUserId = data[0].Id; // Default to the first user
            this.loadObjectives();
        }).catch(error => {
            console.error(error);
        });

        getNearest10Years().then(data => {
            this.yearOptions = data.map(year => ({
                label: year,
                value: year
            }));
            this.selectedYear = this.yearOptions[0].value; // Default to the first year
            this.loadObjectives();
        }).catch(error => {
            console.error(error);
        });
    }

    loadObjectives() {
        if (this.selectedUserId && this.selectedYear) {
            getObjectivesByUserAndYear({ userId: this.selectedUserId, year: this.selectedYear })
                .then(data => {
                    this.objectives = data;
                    this.objectives.forEach(obj => {
                        obj.keyResults = [];
                        getKeyResults({ objectiveId: obj.id }).then(keyResults => {
                            obj.keyResults = keyResults;
                        }).catch(error => {
                            console.error(error);
                        });
                    });
                })
                .catch(error => {
                    console.error(error);
                });
        }
    }

    handleUserSelectionChange(event) {
        this.selectedUserId = event.detail.value;
        this.loadObjectives();
    }

    handleYearSelectionChange(event) {
        this.selectedYear = event.detail.value;
        this.loadObjectives();
    }

    handleInputChange(event) {
        const field = event.target.dataset.id;
        if (field === 'name') {
            this.objectiveName = event.target.value;
        } else if (field === 'year') {
            this.selectedYear = event.target.value;
        } else if (field === 'user') {
            this.selectedUserId = event.target.value;
        }
    }
    

    handleUserChange(event) {
        this.selectedUserId = event.detail.value;
    }

    handleYearChange(event) {
        this.selectedYear = event.detail.value;
    }

    handleShowModal() {
        this.isModalOpen = true;
    }

    handleCloseModal() {
        this.isModalOpen = false;
    }

    handleSave() {
        createObjective({
            name: this.objectiveName,
            year: this.selectedYear,
            userId: this.selectedUserId
        })
        .then(() => {
            this.isModalOpen = false;
            this.showToast('Success', 'Objective created successfully', 'success');
            this.loadObjectives();
        })
        .catch(error => {
            console.error(error);
            this.showToast('Error', 'Error creating objective', 'error');
        });
    }
    

    handleShowNewRelatedRecordModal(event) {
        this.selectedKeyResultId = event.target.dataset.id;
        this.isNewRelatedRecordModalOpen = true;
    }
        
    handleShowNewKeyResultModal(event) {
        this.selectedObjectiveId = event.target.dataset.objectiveId;
        this.isNewKeyResultModalOpen = true;
    }
    handleCloseNewKeyResultModal() {
        this.isNewKeyResultModalOpen = false;
    }

    handleNewKeyResultNameChange(event) {
        this.newKeyResultName = event.target.value;
    }

    handleSaveNewKeyResult() {
        createKeyResult({
            objectiveId: this.selectedObjectiveId,
            name: this.newKeyResultName
        })
            .then(() => {
                this.isNewKeyResultModalOpen = false;
                this.showToast('Success', 'Key Result created successfully', 'success');
                return getKeyResults({ objectiveId: this.selectedObjectiveId });
            })
            .then(result => {
                const updatedObjectives = this.objectives.map(obj => {
                    if (obj.id === this.selectedObjectiveId) {
                        return { ...obj, keyResults: result };
                    }
                    return obj;
                });
                this.objectives = updatedObjectives;
            })
            .catch(error => {
                console.error(error);
                this.showToast('Error', 'Error creating key result', 'error');
            });
    }

    handleShowRelatedRecords(event) {
        this.selectedKeyResultId = event.target.dataset.id;
        getRelatedRecords({ keyResultId: this.selectedKeyResultId })
            .then(result => {
                this.relatedRecords = result;
                this.isRelatedRecordsModalOpen = true;
            })
            .catch(error => {
                console.error(error);
            });
    }

    handleCloseRelatedRecordsModal() {
        this.isRelatedRecordsModalOpen = false;
    }

    handleShowNewRelatedRecordModal(event) {
        this.selectedKeyResultId = event.target.dataset.id;
        this.isNewRelatedRecordModalOpen = true;
    }

    handleCloseNewRelatedRecordModal() {
        this.isNewRelatedRecordModalOpen = false;
    }

    handleRelatedRecordNameChange(event) {
        this.relatedRecordName = event.target.value;
    }

    handleRelatedRecordTypeChange(event) {
        this.relatedRecordType = event.target.value;
    }

    handleSaveRelatedRecord() {
        createRelatedRecord({
            keyResultId: this.selectedKeyResultId,
            recordName: this.relatedRecordName,
            recordType: this.relatedRecordType
        })
        .then(result => {
            this.isNewRelatedRecordModalOpen = false;
            this.showToast('Success', 'Related record created successfully', 'success');
            this.relatedRecords = [...this.relatedRecords, result];
        })
        .catch(error => {
            console.error(error);
            this.showToast('Error', 'Error creating related record', 'error');
        });
    }    
    
    handleShowNewTargetModal(event) {
        this.isNewTargetModalOpen = true;
        this.keyResultIdToAddTarget = event.target.dataset.id;
    }

    handleCloseNewTargetModal() {
        this.isNewTargetModalOpen = false;
        this.selectedTarget = '';
        this.targetScore = 0;
        this.keyResultIdToAddTarget = '';
    }

    // handleTargetSelection(event) {
    //     this.selectedTarget = event.detail.value;
    // }

    // handleTargetScoreChange(event) {
    //     this.targetScore = parseInt(event.target.value, 10);
    // }

    // handleSaveNewTarget() {
    //     addTarget({ keyResultId: this.keyResultIdToAddTarget, targetName: this.selectedTarget, targetScore: this.targetScore })
    //         .then(() => {
    //             this.isNewTargetModalOpen = false;
    //             return refreshApex(this.objectives);
    //         })
    //         .catch(error => {
    //             console.error('Error saving new target: ', JSON.stringify(error));
    //         });
    // }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title,
            message,
            variant,
        });
        this.dispatchEvent(event);
    }
}
