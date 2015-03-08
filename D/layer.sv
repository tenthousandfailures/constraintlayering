package layer;

    typedef enum {READ, WRITE} rw_t;
    
class addr_txn;
    rand bit [31:0] addr;
    rand int size;

    constraint c_size { size inside {1,2,4}; }
endclass
    
class rw_txn extends addr_txn;
    rand rw_t op;

    function void rprint();
        this.randomize();
        this.print();        
    endfunction

    function void print();
        $display("  addr=%h size=%0d", this.addr, this.size);
    endfunction
    
endclass

class addr_constraint_base;
    // TODO need a rand here? - seems to work without it
    addr_txn item;
endclass

class addr_permit extends addr_constraint_base;
    constraint c_addr_permit {
        // Transaction addr range must fit within certain ranges
        item.addr inside {['h00000000 : 'h0000FFFF - item.size]} ||
        item.addr inside {['h10000000 : 'h1FFFFFFF - item.size]};        
    }
endclass

class addr_prohibit extends addr_constraint_base;
    constraint c_addr_prohibit {
        // Transaction addr range must fit within certain ranges
        // transaction must avoid "magic" testbench control addresses
        !(item.addr inside {['h00000000 : 'h00000FFF - item.size]});
    }
endclass

class rw_constrained_txn extends rw_txn;
    rand addr_constraint_base cnst[$];
    addr_permit permit;
    addr_prohibit prohibit;

    function new();
        addr_permit permit = new;
        addr_prohibit prohibit = new;
        cnst = {permit, prohibit};        
    endfunction

    function void pre_randomize;
        foreach(cnst[i]) cnst[i].item = this;
    endfunction
    
endclass
    
endpackage    

module TB ();

    import layer::*;
    layer::rw_constrained_txn rw_constrained_txn;
    
    initial begin
        rw_constrained_txn = new;
        
        $display("\nFIGURE 6. Constraint class using item handle instead of top-level equality constraints:");
        for (int i = 0; i < 5; i++) begin
            rw_constrained_txn.rprint();
        end
        
    end
   
endmodule
