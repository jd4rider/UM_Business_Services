select distinct substr(s.spriden_id, 0, 20) as ID1,
       s.spriden_pidm as ID2,
       'Student' as Role,
       substr(s.spriden_first_name, 0, 20) as FirstName,
       substr(s.spriden_mi, 0, 1) as MiddleInitial,
       substr(s.spriden_last_name, 0, 20) as LastName,
       to_char(p.spbpers_birth_date, 'YYYYMMDD') as BirthDate,
       substr(a.spraddr_street_line1, 0, 30) as StreetAddress1,
       substr(a.spraddr_street_line2, 0, 30) as StreetAddress2,
       substr(a.spraddr_city, 0, 30) as MailingCity,
       substr(a.spraddr_stat_code, 0, 2) as MailingState,
       substr(a.spraddr_zip, 0, 5) as MailingZip,
       (select substr(goremal_email_address, 0, 50)
          from goremal
         where goremal_emal_code = 'UM'
           and goremal_pidm = spriden_pidm) as EmailAddress,
       nvl(substr(p.spbpers_ssn, 6, 4), substr(s.spriden_id, 6, 4)) as SharedSecret,
       substr(p.spbpers_sex, 0, 1) as Gender,
       (select substr(t.sprtele_phone_area || t.sprtele_phone_number, 0, 10)
          from sprtele t
         where t.sprtele_pidm = a.spraddr_pidm
           and t.sprtele_atyp_code = a.spraddr_atyp_code
           and t.sprtele_addr_seqno = a.spraddr_seqno
           and t.sprtele_primary_ind = 'Y'
           and t.sprtele_status_ind is null) as PhoneNumber
 from spriden s, spbpers p, spraddr a 
 where s.spriden_pidm = p.spbpers_pidm
   and s.spriden_change_ind is null
   and p.spbpers_dead_ind is null
   and a.spraddr_pidm = s.spriden_pidm
   and a.spraddr_atyp_code = 'MA'
   and a.spraddr_status_ind is null
   and (a.spraddr_to_date is null OR a.spraddr_to_date > trunc(sysdate))
   and exists 
       (select 'x'
          from sgbstdn a, stvterm, sfrstcr
         where sfrstcr_pidm = s.spriden_pidm
           and stvterm_code = sfrstcr_term_code
           and stvterm_end_date > trunc(sysdate)
           and (substr(sfrstcr_term_code,5,6) in ('30','35','50') or
               (substr(sfrstcr_term_code,5,6) in ('70','75') and
                 to_char(sysdate,'MMDD') >= '0715'
               ))
           and sfrstcr_rsts_code in ('RE', 'RS')
           and a.sgbstdn_pidm = s.spriden_pidm
           and a.sgbstdn_term_code_eff =
               (select max(b.sgbstdn_term_code_eff)
                  from sgbstdn b
                 where b.sgbstdn_pidm = a.sgbstdn_pidm
                   and b.sgbstdn_term_code_eff <= sfrstcr_term_code)
           and a.sgbstdn_admt_code not like 'H%'
           )
   and not exists 
       (select 'x'
       from evibchoc
       where evibchoc_id = s.spriden_id
       and evibchoc_status <> 'R')
;
