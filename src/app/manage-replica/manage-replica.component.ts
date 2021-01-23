import { Component, ElementRef, OnInit, ViewChild } from '@angular/core';
import { FormControl, FormGroup, NgForm } from '@angular/forms';
import { ActivatedRoute, Router } from '@angular/router';
import { first } from 'rxjs/operators';
import { Replica } from '../shared/models/replica.model';
import { ReplicaService } from '../shared/services/replica.service';

@Component({
  selector: 'app-manage-replica',
  templateUrl: './manage-replica.component.html',
  styleUrls: ['./manage-replica.component.scss']
})
export class ManageReplicaComponent implements OnInit {
    @ViewChild('form', { static: false }) form: NgForm;
    // @Output() hasErrors: boolean = false
    formLoaded: boolean = false;
    isLoading = false;
    hasErrors = false;
    manageType = 'update';

    constructor(
        private elementRef: ElementRef,
        // private accountService: AccountService,
        private replicaService: ReplicaService,
        private router: Router,
        private route: ActivatedRoute,
    ) { }

    ngOnInit(): void {
        this.route.data.pipe(first()).subscribe((data) => {
            if (data.manageType != 'create') {
                this.route.params.pipe(first()).subscribe(params => {
                    if (!params.id) return;
        
                    this.replicaService.getReplicaById(params.id)
                    .pipe(first())
                    .subscribe(
                        res => {
                            this.form.setValue({
                                artist: res.body.replica.artist,
                                name: res.body.replica.name,
                                origin: res.body.replica.origin,
                                cost: res.body.replica.cost,
                                image_url: res.body.replica.image_url,
                                year: res.body.replica.year
                            });
        
                            this.formLoaded = true;
                        },
                        () => {
                            this.hasErrors = true;
                            this.form.reset();
        
                            this.form.statusChanges.pipe(first()).subscribe(res => { if (this.hasErrors) this.hasErrors = false; });
                        }
                    )
                })
            } else {
                this.manageType = data.manageType;
                this.formLoaded = true;
            }
        });

        this.elementRef.nativeElement.ownerDocument.body.classList.add('grey-body');
    }

    onSubmit(form: NgForm) {
        if (this.manageType == 'create')
            this.replicaService.createReplica({
                artist: this.form.control.get('artist').value,
                name: this.form.control.get('name').value,
                origin: this.form.control.get('origin').value,
                year: this.form.control.get('year').value,
                cost: this.form.control.get('cost').value,
                image_url: this.form.control.get('image_url').value 
            })
            .pipe(first())
            .subscribe(
                () => {
                    this.router.navigate(['manage'])
                },
                () => {
                    this.hasErrors = true;

                    this.form.statusChanges.pipe(first()).subscribe(res => { if (this.hasErrors) this.hasErrors = false; });
                }
            )
        else
            this.route.params.pipe(first()).subscribe(params => {
                if (!params.id) return;

                this.replicaService.updateReplicaById({
                    artist: this.form.control.get('artist').value,
                    name: this.form.control.get('name').value,
                    origin: this.form.control.get('origin').value,
                    year: this.form.control.get('year').value,
                    cost: this.form.control.get('cost').value,
                    image_url: this.form.control.get('image_url').value 
                }, params.id)
                .pipe(first())
                .subscribe(
                    () => {
                        this.router.navigate(['manage'])
                    },
                    () => {
                        this.hasErrors = true;

                        this.form.statusChanges.pipe(first()).subscribe(res => { if (this.hasErrors) this.hasErrors = false; });
                    }
                )
            })
    }

    ngOnDestroy(): void {
        this.elementRef.nativeElement.ownerDocument.body.classList.remove('grey-body');
    }
}
