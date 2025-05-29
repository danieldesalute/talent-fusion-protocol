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


;; ================================================================================
;; PROFILE MANAGEMENT - PROFESSIONALS
;; ================================================================================

;; Register a new professional on the platform
(define-public (register-professional 
    (name (string-ascii 100))
    (skills (list 10 (string-ascii 50)))
    (location (string-ascii 100))
    (bio (string-ascii 500)))
    (let
        (
            (user tx-sender)
            (existing-profile (map-get? professional-records user))
        )
        ;; Verify this account hasn't already registered
        (if (is-none existing-profile)
            (begin
                ;; Validate all input fields meet requirements
                (if (or (is-eq name "")
                        (is-eq location "")
                        (is-eq (len skills) u0)
                        (is-eq bio ""))
                    (err ERR-INVALID-BIO)
                    (begin
                        ;; Store the new professional record
                        (map-set professional-records user
                            {
                                name: name,
                                skills: skills,
                                location: location,
                                bio: bio
                            }
                        )
                        (ok "Professional profile created successfully.")
                    )
                )
            )
            (err ERR-ALREADY-EXISTS)
        )
    )
)























;; Modify an existing professional profile
(define-public (edit-professional-profile 
    (name (string-ascii 100))
    (skills (list 10 (string-ascii 50)))
    (location (string-ascii 100))
    (bio (string-ascii 500)))
    (let
        (
            (user tx-sender)
            (existing-profile (map-get? professional-records user))
        )
        ;; Verify profile exists before updating
        (if (is-some existing-profile)
            (begin
                ;; Validate all updated fields meet requirements
                (if (or (is-eq name "")
                        (is-eq location "")
                        (is-eq (len skills) u0)
                        (is-eq bio ""))
                    (err ERR-INVALID-BIO)
                    (begin
                        ;; Update the professional record with new information
                        (map-set professional-records user
                            {
                                name: name,
                                skills: skills,
                                location: location,
                                bio: bio
                            }
                        )
                        (ok "Professional profile updated successfully.")
                    )
                )
            )
            (err ERR-PROFILE-MISSING)
        )
    )
)

;; Delete professional profile from the platform
(define-public (deactivate-professional-profile)
    (let
        (
            (user tx-sender)
            (existing-profile (map-get? professional-records user))
        )
        ;; Ensure profile exists before attempting deletion
        (if (is-some existing-profile)
            (begin
                ;; Remove the professional profile completely
                (map-delete professional-records user)
                (ok "Professional profile deactivated successfully.")
            )
            (err ERR-PROFILE-MISSING)
        )
    )
)

;; ================================================================================
;; PROFILE MANAGEMENT - ORGANIZATIONS
;; ================================================================================

;; Register a new organization on the platform
(define-public (register-organization 
    (name (string-ascii 100))
    (industry (string-ascii 50))
    (location (string-ascii 100)))
    (let
        (
            (user tx-sender)
            (existing-org (map-get? organization-records user))
        )
        ;; Check if organization already exists
        (if (is-none existing-org)
            (begin
                ;; Verify all required fields have values
                (if (or (is-eq name "")
                        (is-eq industry "")
                        (is-eq location ""))
                    (err ERR-INVALID-LOCATION)
                    (begin
                        ;; Create new organization record
                        (map-set organization-records user
                            {
                                name: name,
                                industry: industry,
                                location: location
                            }
                        )
                        (ok "Organization profile created successfully.")
                    )
                )
            )
            (err ERR-ALREADY-EXISTS)
        )
    )
)

;; Update an existing organization's information
(define-public (edit-organization-profile 
    (name (string-ascii 100))
    (industry (string-ascii 50))
    (location (string-ascii 100)))
    (let
        (
            (user tx-sender)
            (existing-org (map-get? organization-records user))
        )
        ;; Verify organization profile exists
        (if (is-some existing-org)
            (begin
                ;; Validate all required fields
                (if (or (is-eq name "")
                        (is-eq industry "")
                        (is-eq location ""))
                    (err ERR-INVALID-LOCATION)
                    (begin
                        ;; Update organization record with new details
                        (map-set organization-records user
                            {
                                name: name,
                                industry: industry,
                                location: location
                            }
                        )
                        (ok "Organization profile updated successfully.")
                    )
                )
            )
            (err ERR-PROFILE-MISSING)
        )
    )
)

;; Remove an organization profile from the platform
(define-public (deactivate-organization-profile)
    (let
        (
            (user tx-sender)
            (existing-org (map-get? organization-records user))
        )
        ;; Verify organization exists before deletion
        (if (is-some existing-org)
            (begin
                ;; Remove the organization record completely
                (map-delete organization-records user)
                (ok "Organization profile deactivated successfully.")
            )
            (err ERR-PROFILE-MISSING)
        )
    )
)

;; ================================================================================
;; DATA RETRIEVAL FUNCTIONS
;; ================================================================================

;; Retrieve professional data by account identifier
(define-read-only (get-professional-info (account-id principal))
    (match (map-get? professional-records account-id)
        profile-data (ok profile-data)
        ERR-NOT-FOUND
    )
)

;; Retrieve organization data by account identifier
(define-read-only (get-organization-info (account-id principal))
    (match (map-get? organization-records account-id)
        org-data (ok org-data)
        ERR-NOT-FOUND
    )
)

;; Retrieve job listing by its unique identifier
(define-read-only (get-job-info (listing-id principal))
    (match (map-get? job-listings listing-id)
        job-data (ok job-data)
        ERR-NOT-FOUND
    )
)


;; ================================================================================
;; JOB LISTING MANAGEMENT
;; ================================================================================

;; Create a new job opportunity listing
(define-public (create-job-listing 
    (title (string-ascii 100))
    (description (string-ascii 500))
    (location (string-ascii 100))
    (requirements (list 10 (string-ascii 50))))
    (let
        (
            (user tx-sender)
            (existing-listing (map-get? job-listings user))
        )
        ;; Check if user already has an active listing
        (if (is-none existing-listing)
            (begin
                ;; Ensure all required fields are valid
                (if (or (is-eq title "")
                        (is-eq description "")
                        (is-eq location "")
                        (is-eq (len requirements) u0))
                    (err ERR-INVALID-LISTING)
                    (begin
                        ;; Create the new job listing
                        (map-set job-listings user
                            {
                                title: title,
                                description: description,
                                creator: user,
                                location: location,
                                requirements: requirements
                            }
                        )
                        (ok "Job listing created successfully.")
                    )
                )
            )
            (err ERR-ALREADY-EXISTS)
        )
    )
)

;; Modify an existing job listing
(define-public (update-job-listing 
    (title (string-ascii 100))
    (description (string-ascii 500))
    (location (string-ascii 100))
    (requirements (list 10 (string-ascii 50))))
    (let
        (
            (user tx-sender)
            (existing-listing (map-get? job-listings user))
        )
        ;; Verify listing exists before updating
        (if (is-some existing-listing)
            (begin
                ;; Validate all fields meet requirements
                (if (or (is-eq title "")
                        (is-eq description "")
                        (is-eq location "")
                        (is-eq (len requirements) u0))
                    (err ERR-INVALID-LISTING)
                    (begin
                        ;; Update the job listing with new details
                        (map-set job-listings user
                            {
                                title: title,
                                description: description,
                                creator: user,
                                location: location,
                                requirements: requirements
                            }
                        )
                        (ok "Job listing updated successfully.")
                    )
                )
            )
            (err ERR-PROFILE-MISSING)
        )
    )
)

;; Remove a job listing from the platform
(define-public (close-job-listing)
    (let
        (
            (user tx-sender)
            (existing-listing (map-get? job-listings user))
        )
        ;; Verify listing exists before removal
        (if (is-some existing-listing)
            (begin
                ;; Delete the job listing record
                (map-delete job-listings user)
                (ok "Job listing closed successfully.")
            )
            (err ERR-PROFILE-MISSING)
        )
    )
)

