import { ComponentFixture, TestBed } from '@angular/core/testing';

import { ReplicasOverviewComponent } from './replicas-overview.component';

describe('ReplicasOverviewComponent', () => {
  let component: ReplicasOverviewComponent;
  let fixture: ComponentFixture<ReplicasOverviewComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      declarations: [ ReplicasOverviewComponent ]
    })
    .compileComponents();
  });

  beforeEach(() => {
    fixture = TestBed.createComponent(ReplicasOverviewComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
