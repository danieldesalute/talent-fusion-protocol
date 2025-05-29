;; TalentFusion Protocol
;; A distributed platform for skilled professionals and organizations to connect
;; Enabling secure profile management, skills verification, and project opportunity discovery
;; This contract handles professional registration, organization onboarding, and job listing creation

;; ================================================================================
;; CONSTANTS & ERROR DEFINITIONS
;; ================================================================================

;; Standard error responses for improved debugging and user feedback
(define-constant ERR-NOT-FOUND (err u404))
(define-constant ERR-ALREADY-EXISTS (err u409))
(define-constant ERR-BAD-SKILLS-INPUT (err u400))
(define-constant ERR-INVALID-LOCATION (err u401))
(define-constant ERR-INVALID-BIO (err u402))
(define-constant ERR-INVALID-LISTING (err u403))
(define-constant ERR-PROFILE-MISSING (err u404))

;; ================================================================================
;; STORAGE MAPS
;; ================================================================================

;; Storage for individual professional records
(define-map professional-records
    principal
    {
        name: (string-ascii 100),
        skills: (list 10 (string-ascii 50)),
        location: (string-ascii 100),
        bio: (string-ascii 500)
    }
)

;; Storage for organization accounts
(define-map organization-records
    principal
    {
        name: (string-ascii 100),
        industry: (string-ascii 50),
        location: (string-ascii 100)
    }
)

;; Storage for job opportunities
(define-map job-listings
    principal
    {
        title: (string-ascii 100),
        description: (string-ascii 500),
        creator: principal,
        location: (string-ascii 100),
        requirements: (list 10 (string-ascii 50))
    }
)
