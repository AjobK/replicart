import { Component, Input, OnInit } from '@angular/core';

@Component({
    selector: 'app-pop-up',
    templateUrl: './pop-up.component.html',
    styleUrls: ['./pop-up.component.scss']
})
export class PopUpComponent implements OnInit {
    @Input() message: string;

    constructor() { }

    ngOnInit(): void {
    }

    close(): void {
        this.message = undefined;
    }
}
