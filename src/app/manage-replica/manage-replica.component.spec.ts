import { ComponentFixture, TestBed } from '@angular/core/testing';

import { ManageReplicaComponent } from './manage-replica.component';

describe('ManageReplicaComponent', () => {
  let component: ManageReplicaComponent;
  let fixture: ComponentFixture<ManageReplicaComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      declarations: [ ManageReplicaComponent ]
    })
    .compileComponents();
  });

  beforeEach(() => {
    fixture = TestBed.createComponent(ManageReplicaComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
