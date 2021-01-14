import { ComponentFixture, TestBed } from '@angular/core/testing';

import { ReplicaBlockComponent } from './replica-block.component';

describe('ReplicaBlockComponent', () => {
  let component: ReplicaBlockComponent;
  let fixture: ComponentFixture<ReplicaBlockComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      declarations: [ ReplicaBlockComponent ]
    })
    .compileComponents();
  });

  beforeEach(() => {
    fixture = TestBed.createComponent(ReplicaBlockComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
