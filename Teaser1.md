## 1. Project Douglas: a first glimpse

### A. Objectives

We intend to build and test the first decentralised autonomous organisation (**DAO**) which is incorporated into a legal entity’s governance structure. It is our intention for the DAO to serve as a technology demonstrator for a decentralised and consensus-based organisational governance, on a fully transparent and trustless basis, which to our knowledge has not yet been attempted. We furthermore intend to design the DAO in such a way that it is run in full compliance with legal and regulatory obligations. 

A DAO is an algorithmically-governed quasi-corporation or unincorporated association, operating itself in accordance with pre-defined rules and cryptographically secure architecture such that its users can rely that instructions which they broadcast to a DAO will consistently be executed in a reliable way. 

Viewed thus, Bitcoin itself is a DAO, albeit one currently capable of executing only one-way instructions. Until recently, DAOs capable of a higher degree of sophistication existed only in theory. More recent iterations require a high degree of technical aptitude to use - or to find relevant for use - and therefore have failed to capture the public imagination. 

We are intending to release version 0.1 (the Project Douglas software is as-yet unnamed) by 11:59 PM (Greenwich Time) on Monday, 16th of June, 2014. 

### B. Primary Use-Case

It is our belief that the proliferation of DAOs in user-friendly applications has the potential to allow the public to claim back control over their data and over their privacy on the internet. Current free-to-use internet services, from search to e-mail to social networking, are dependent on advertising revenue to fund their operations. As a result, companies offering these services must - to paraphrase Satoshi Nakamoto - ‘hassle their users for considerably more information than they would otherwise need.’

Where Bitcoin was designed to solve this problem in relation to point-of-sale and banking transactions, Project Douglas was conceived in order to solve this issue for internet-based communications and social networking - bearing in mind that free internet services and "big data" applications, intrusion into users' private lives is not merely a nuisance, but a  design imperative. 

We will pair our DAO with a non-profit organisation, name TBD but currently being referred to as "the Association." The DAO will be a captive software platform of this nonprofit (and in this role, the specific DAO we have created will be known hereafter as the **ADAO**)

The ADAO will initially be run on the Ethereum testnet, in relation to which the underlying units of testnet Ether presently are (and will likely forever be) completely valueless in exchange. However, the experience of Bitcoin has demonstrated powerfully that the enterprise value of decentralised networks operating on this basis can and does capitalise into the value of tokens they issue. We do not, therefore, think it unreasonable to expect that "2.0" platforms such as Ethereum or ones similar to it have the potential to thrive in a similar fashion, allowing the creation of free-of-charge services which incentivise privacy through their very design.

## 2. A Very Brief Overview of Functionality

Our DAO is completely serverless and offers a wide range of functionality. Specifically:

1. decentralised forums;

2. decentralised crowdfunding;

3. decentralised voting;

4. decentralised Reputation Scoring on three "Branches":

    1. Citizenship (representation and lobbying, polling Community sentiment and opinion);

    2. Development (maintaining and upgrading the ADAO); and

    3. Moderation (flagging content and assessing and resolving disputes)

5. decentralised voting (user communication to the Association on issues of significant importance or policy positions).

The integration of decentralised bilateral messaging has been set as a medium-term objective and does not form part of this proposal. We take the view, however, that this is an essential piece of creating a decentralised social network. We hope that (quite irrespective of the Olivier Janssens bounty) if the Community judges our proposal sufficiently worthy of merit, new volunteers will join our very small dev team to help us to include this functionality.

## 3. Pairing with Non-Profit Entity

We also believe that the ADAO will be more effective as a representative and educational tool if it is paired with a non-profit entity and expected to operate within legally permissible parameters (the exact form of business organisation is not yet settled). The Association will be incorporated as this entity and will be wholly dependent on donations from the public or project-based grants from research institutes to carry out its operations; members of its Board (being volunteers) will not enjoy any personal benefit from or rights to these funds.

The Association may, at its discretion, grant individuals and organisations donating more than USD$25 or other cryptocurrency equivalent (Bitcoin, Dogecoin and Litecoin) access the ADAO. Higher levels of donation will not grant additional rights of access.  If Ether is used as the method of payment, the grant of access will be wholly automated. Donation through any other means will be routed through a trusted silo.

The Association will, furthermore, have a number of discretionary powers in relation to the DAO which we have coded for.

## 4. Platform architecture

### A. Decentralisation Architecture

Using:

1. the Ethereum blockchain (the **Blockchain**);

2. a constitutional smart contract which will operate on the back-end (the Ethereum layer) to organise and launch blockchain-based contracts (such constitutional contract being known as **DOUG** (to avoid any confusion, this is DOUG pronounced as in "Douglas")); DOUG acts as the kernel of the ADAO and provides a core of functionality which can be expanded with submodules built and integrated into its core functionality over time;

3. Factory Contracts (described more particularly below) which provide standard-form contracts for specific purposes (e.g. for consensus-gathering functionality or specific fundraising efforts, or standalone smart loans) which DOUG can (if desired) deploy to the blockchain and track;

4. a DOUG-compatible data storage and recall facility (**Contract Controlled Content Dissemination Program**, also **CCCD** or **C3D**) which utilises BitTorrent to store, disseminate, and recall contract-specific data (with which DOUG will interact in order to support the execution and settlement of Factory Contracts); and

5. an application-specific user interface framework (**Kanopy**) which is able to synthesise information between DOUG and C3D,

we propose to deploy, for the first time, a decentralised smart contract platform which is useable by ordinary people in everyday applications.

### B. Functionality

##### C3D: standardising smart contracts

c3D contracts have a standardized structure which is used by the c3D system to push and pull information to the contracts. By standardizing the interfaces, we are able to provide users and the DAO itself with unparalleled extensibility.

*Notes*: in the below documentation storage slots can hold different types of data. These are the types of data used in the documentation:

* (A) indicates this field points to a Storage address
* (B) indicates this field should be filled with a blob_id value
* (C) indicates this field should be filled with a contract address
* (B||C) indicate either (B) or (C) is accepted
* (K) indicates this field should be a (public) Address
* (I) indicates this field is an indicator and can take one of the values in []
* (V) indicates a value

##### DOUG and c3D Contract Types

c3D contracts come in four flavors, each of which is connoted in the 0x10 storage slot:

1. 0x10 : (I) : 0x88554646AA -- Action Contract Only (no c3D data is attached to this contract)
2. 0x10 : (I) : 0x88554646AB -- c3D Content (data) Contract
3. 0x10 : (I) : 0x88554646BA -- c3D Structural (meta) Contract
4. 0x10 : (I) : 0x88554646BB -- Action Contract + c3D Structural Contract

For the purposes of this documentation, `AA` contracts are simply indicators for the c3D system. c3D will take no action when a DAO link points to an `AA` contract.

Similarly `BB` contracts are mirrors of `BA` contracts and the c3D system will simply treat them as `BA` contracts. See below for further information on `AB` and `BA` contracts.

##### BA Contracts -- c3D Structural Contracts

Top Level Contract Storage Slots:

* 0x10 : (I)    : [0x88554646BA]
* 0x11 : (B||C) : pointer to an applicable datamodel.json
* 0x12 : (B||C) : pointer to an applicable set (or single) of UI file(s) structure
* 0x13 : (B||C) : content
* 0x14 : (C)    : Parent of this c3D contract
* 0x15 : (K)    : Owner of this c3D contract
* 0x16 : (C)    : Creator of this c3D contract
* 0x17 : (V)    : TimeStamp this c3D contract was created
* 0x18 : (A)    : Linked list start

##### Helpful Compatibility Definitions for Top Level Storage (primarily used by DOUG Bylaws):

```lisp
(def 'indicator 0x10)
(def 'dmpointer 0x11)
(def 'UIpointer 0x12)
(def 'blob)
(def 'parent 0x14)
(def 'owner 0x15)
(def 'creator 0x16)
(def 'time 0x17)
(def 'LLstart 0x13)
```

##### Individual Entity Entries

* (linkID)+0 : (A)    : ContractTarget (for DOUG NameReg)
* (linkID)+1 : (A)    : Previous link
* (linkID)+2 : (A)    : Next link
* (linkID)+3 : (I)    : Type [ 0 => Contract || 1 => Blob || 2 => Datamodel Only ]
* (linkID)+4 : (V)    : Behaviour [0 => Ignore || 1 => Treat Normally || 2 => UI structure ||
                                        3 => Flash Notice || 4 => Datamodel list || 5 => Blacklist]
* (linkID)+5 : (B||C) : Content
* (linkID)+6 : (B||C) : Datamodel.json (*note*: if the content is a pointer to an `AB` contract this would typically be blank)
* (linkID)+7 : (B||C) : UI structure (*note*: if the content is a pointer to an `AB` contract this would typically be blank)
* (linkID)+8 : (V)    : Timestamp

##### Helpful Compatibility Definitions for Linked List Entries (primarily used by DOUGs ByLaws)

```lisp
(def 'nextslot (addr) (+ addr 2))
(def 'nextlink (addr) @@(+ addr 2))
(def 'prevslot (addr) (+ addr 1))
(def 'prevlink (addr) @@(+ addr 1))
(def 'typeslot (addr) (+ addr 3))
(def 'behaviourslot (addr) (+ addr 4))
(def 'dataslot (addr) (+ addr 5))
(def 'modelslot (addr) (+ addr 6))
(def 'UIlot (addr) (+ addr 7))
(def 'timeslot (addr) (+ addr 8))
```

##### AB Contracts -- c3D Content Contract

###### Top Level Contract Storage Slots

* 0x10 : (I)    : [0x88554646AB]
* 0x11 : (B||C) : Datamodel.json
* 0x12 : (B||C) : UI structure
* 0x13 : (B)    : content
* 0x14 : (C)    : Parent
* 0x15 : (K)    : Owner
* 0x16 : (C)    : Creator
* 0x17 : (V)    : TimeStamp

##### Helpful Compatibility Definitions for Top Level Storage (primarily used by DOUGs ByLaws)

```lisp
(def 'indicator 0x10)
(def 'dmpointer 0x11)
(def 'UIpointer 0x12)
(def 'content 0x13)
(def 'parent 0x14)
(def 'owner 0x15)
(def 'creator 0x16)
(def 'time 0x17)
```

### C. API

Users will experience the c3D/DOUG architecture through a simple user interface. As the platform evolves user experience will be made paramount, with the general idea (and end goal) being that users should be able to use the platform without being able to tell the difference between it and, for example, Facebook or Reddit. 

Unlike Facebook or Reddit, though, users will benefit from decentralisation and encryption and will be able to mount trustless peer-to-peer contracts.

In principle, any agreement which is reducible to code is amenable to expression in this way; because they are standardised they can be replicated, allowing transaction-specific individual contracts to be generated. These contracts can be either standalone (and thus settled on a peer-to-peer basis) or by reference to DOUG (in the case of the consensus-gathering and Community-driven functions outlined more particularly below). Version 0.1 of the Project Douglas platform will incorporate the following factory functions:

1. Thread Factories (will allow the creation of threads on the decentralised forums);
2. Topic Factories; and
3. Votable Post Factories. 

It is envisaged that as development of the ADAO progresses and a greater degree of certainty is achieved, Factory-made contracts will be linked to off-chain legal agreements and identification procedures in order to permit, e.g,. the taking of security, the incorporation of trustless arbitration (as proposed by Vitalik Buterin), or the possibility of real-world enforcement. The extent to which this added functionality is available and useable under the aegis of the ADAO will be largely dependent on the availability of appropriate code, contributed by the Community, capable of incorporating these legal obligations by reference, as well as market demand.
